--DROP FUNCTION find_indoor_exteriors(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION find_indoor_exteriors(
    IN b_id     INTEGER,
    IN from_id  INTEGER
) 
RETURNS TABLE(
    exit_id     INTEGER,
    dist        DOUBLE PRECISION,
    geom        GEOMETRY) AS 
$BODY$
BEGIN
    RETURN QUERY SELECT nd.node_id, ind.dist, ind.path
                FROM building_node nd, indoor_dijkstra(from_id, nd.node_id, b_id) ind
                WHERE nd.exterior is true;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT; 