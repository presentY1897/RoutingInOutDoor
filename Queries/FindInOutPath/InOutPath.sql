--DROP FUNCTION find_bus_to_indoor_path;

CREATE OR REPLACE FUNCTION find_bus_to_indoor_path(
    IN start_station_id INTEGER,
    IN start_time INTEGER,
    IN end_node_id NUMERIC,
    OUT seq INTEGER,
    OUT geom GEOMETRY
) 
RETURNS SETOF RECORD AS 
$BODY$
DECLARE
    find_indoor_sql TEXT; -- 실내 경로 탐색 쿼리
    find_nearest_station_sql TEXT; -- 근처 정류장 탐색 쿼리
    exteriors INTEGER[]; -- 건물 출입구
    stations INTEGER[]; -- 건물 출입구 근처 정류장
    k INTEGER;
    new_stop INTEGER;
    rec RECORD;
    rec_t RECORD;
    rec_s RECORD;
    rec_r RECORD;
BEGIN
    exteriors := '{}';
    FOR rec IN SELECT nd.node_id, pgr_dijkstra('
                SELECT link_id::integer AS id,
                         source::integer,
                         target::integer,
                         dist::double precision AS cost
                        FROM building_link',
                CAST(end_node_id AS INTEGER)
                , nd.node_id, false, false)
                FROM building_node nd
                WHERE nd.exterior is true
    LOOP
        exteriors := array_remove(exteriors, rec.node_id);
        exteriors := array_append(exteriors, rec.node_id);
    END LOOP;

    stations := ARRAY(SELECT DISTINCT p_st.pseudo_id FROM p_st JOIN 
        (SELECT ex.geom FROM building_node ex WHERE ex.node_id = ANY(exteriors)) nd ON ST_Distance(ST_Transform(p_st.geom, 3857), ST_Transform(nd.geom, 3857)) < 700);
    
    -- 대중교통 탐색
    seq := 0;
    FOR rec_r IN SELECT R.route_id, R.dep_time, R.arr_time, DP.station_id AS d_id, AP.station_id  AS a_id , rdd.seq AS d_seq, rda.seq AS a_seq,
                CASE WHEN R.route_id = -2 THEN ST_MakeLine((SELECT DISTINCT st.geom FROM p_st st WHERE st.pseudo_id = DP.pseudo_id), (SELECT DISTINCT st.geom FROM p_st st WHERE st.pseudo_id = AP.pseudo_id))
                ELSE ST_MakeLine(ARRAY(SELECT rl.geom FROM route_link rl WHERE rl.route_id = R.route_id AND rl.seq BETWEEN rdd.seq AND rda.seq - 1)) END AS geom																																		   
                FROM raptor_find_route_in_stations(start_station_id, start_time, stations) R
                    JOIN p_st DP
                    ON R.dep_st = DP.pseudo_id
                    JOIN p_st AP
                    ON R.arr_st = AP.pseudo_id
                    LEFT JOIN route_st rdd
                    ON rdd.route_id = R.route_id AND rdd.station_id = DP.station_id
                    LEFT JOIN route_st rda
                    ON rda.route_id = R.route_id AND rda.station_id = AP.station_id
                ORDER BY R.path_seq DESC
    LOOP
        -- Return record
        seq     := seq + 1;
        geom    := rec_r.geom;
        RETURN NEXT;
    END LOOP;
    -- ped route
    seq := seq + 1;
    geom := ST_MakeLine((SELECT bn.geom FROM building_node bn WHERE node_id = ANY(exteriors) ORDER BY ST_Distance(bn.geom, ST_EndPoint(rec_r.geom)) LIMIT 1), 
    ST_EndPoint(rec_r.geom));
    RETURN NEXT;
    -- indoor route
    seq := seq + 1;
    geom := (SELECT ST_MakeLine(ARRAY(SELECT bn.geom
    FROM pgr_dijkstra('SELECT link_id::integer AS id,
                         source::integer,
                         target::integer,
                         dist::double precision AS cost
                        FROM building_link',
                CAST(end_node_id AS INTEGER) , 
                (SELECT ex.node_id FROM (SELECT bn.geom, node_id FROM building_node bn WHERE node_id = ANY(exteriors)) ex ORDER BY ST_Distance(ex.geom, ST_EndPoint(rec_r.geom)) LIMIT 1)
                , false, false) di
    JOIN building_node bn
    ON di.id1 = bn.node_id)));

    RETURN NEXT;
    RETURN;
END;
$BODY$ 
LANGUAGE 'plpgsql' VOLATILE STRICT; 