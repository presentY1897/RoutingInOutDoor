--DROP FUNCTION find_nearest_stations(INTEGER, INTEGER, DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION find_nearest_stations(
    IN building_id INTEGER,
    IN from_id INTEGER,
    IN distance DOUBLE PRECISION -- 탐색할 이동 거리
) 
RETURNS TABLE(
    station_id INTEGER) AS 
$BODY$
BEGIN
    RETURN QUERY SELECT pst.pseuod_id
                FROM building_node bn
                JOIN p_st pst
                ON ST_Distance(ST_Transform())
                WHERE 
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT; 