--DROP FUNCTION public_dijkstra(INTEGER, INTEGER, INTEGER[]);

CREATE OR REPLACE FUNCTION public_dijkstra(
    IN start_station_id INTEGER,
    IN start_time INTEGER,
    IN end_pts_id INTEGER[],
    OUT path GEOMETRY,
    OUT dist DOUBLE PRECISION,
    OUT arr_st_id INTEGER
) 
RETURNS SETOF RECORD AS 
$BODY$
BEGIN
    RETURN QUERY SELECT ST_MakeLine(R.geom), SUM(ST_Length(ST_Transform(R.geom, 3857))), MIN(R.arr)   
        FROM (
        SELECT --R.route_id, R.dep_time, R.arr_time, DP.station_id AS d_id, AP.station_id  AS a_id, rdd.seq AS d_seq, rda.seq AS a_seq,
            CASE WHEN R.route_id = -2 THEN ST_MakeLine((SELECT DISTINCT st.geom FROM p_st st WHERE st.pseudo_id = DP.pseudo_id), (SELECT DISTINCT st.geom FROM p_st st WHERE st.pseudo_id = AP.pseudo_id))
            ELSE ST_MakeLine(ARRAY(SELECT rl.geom FROM route_link rl WHERE rl.route_id = R.route_id AND rl.seq BETWEEN rdd.seq AND rda.seq - 1)) END AS geom,
            first_value(CAST(R.arr_st AS INTEGER)) OVER(ORDER BY R.path_seq) arr -- raptor_find_route_in_stations 함수에서 아웃하는 변수를 integer로 바꾸어야함
            FROM raptor_find_route_in_stations(start_station_id, start_time, end_pts_id) R
                JOIN p_st DP
                ON R.dep_st = DP.pseudo_id
                JOIN p_st AP
                ON R.arr_st = AP.pseudo_id
                LEFT JOIN route_st rdd
                ON rdd.route_id = R.route_id AND rdd.station_id = DP.station_id
                LEFT JOIN route_st rda
                ON rda.route_id = R.route_id AND rda.station_id = AP.station_id
            ORDER BY R.path_seq DESC) R;
END;
$BODY$ 
LANGUAGE 'plpgsql' VOLATILE STRICT;