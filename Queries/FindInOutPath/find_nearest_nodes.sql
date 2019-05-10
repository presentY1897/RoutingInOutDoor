--DROP FUNCTION find_nearest_nodes(INTEGER, INTEGER, DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION find_nearest_nodes(
    IN b_id     INTEGER, -- 건물 id
    IN from_id  INTEGER,
    IN distance DOUBLE PRECISION -- 탐색할 이동 거리
) 
RETURNS TABLE(
    n_id        INTEGER,
    dist        DOUBLE PRECISION,
    geom        GEOMETRY) AS 
$BODY$
BEGIN
    RETURN QUERY SELECT DISTINCT nd.gid, 
    ST_Distance(ST_Transform(bn.geom, 3857), ST_Transform(nd.geom, 3857)) as dist, 
    ST_MakeLine(bn.geom, nd.geom) as geom
                FROM building_node bn
                JOIN its_node nd
                ON ST_Distance(ST_Transform(bn.geom, 3857), ST_Transform(nd.geom, 3857)) <= distance
                WHERE bn.building_id = b_id AND bn.node_id = from_id;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT; 