--DROP FUNCTION find_bus_to_indoor_path;

CREATE OR REPLACE FUNCTION find_bus_to_indoor_path(
    IN start_station_id NUMERIC,
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
    deps trip[];
    Q tripQ[];
    marked_stop INTEGER[];
    marked_stop_t INTEGER[];
    k INTEGER;
    new_stop INTEGER;
    rec RECORD;
    rec_s RECORD;
    rec_sql TEXT;
    seq INTEGER;
BEGIN
    find_indoor_sql := '''
                SELECT jn.gid, pgr_dijkstra(\'
                SELECT gid AS id,
                         fpoint_id::integer AS source,
                         spoint_id::integer AS target,
                         length::double precision AS cost
                        FROM jeju_link\','''
                || end_node_id
                || ', jn.gid, false, false)
                FROM jeju_node jn
                WHERE jn.exterior is true';

    EXECUTE find_indoor_sql INTO rec;

    FOREACH node IN REC
    LOOP
        find_nearest_station_sql := '''
                    SELECT *, ST_Distance('''
                    || node.geom
                    || ' , st.geom) AS dist
                    FROM station st
                    WHERE ST_Distance('
                    || node.geom
                    || ' , st.geom) < 700';
                    
        EXECUTE find_nearest_station_sql INTO rec_s;
    END LOOP;


    RETURN;
END;
$BODY$ 
LANGUAGE 'plpgsql' VOLATILE STRICT;