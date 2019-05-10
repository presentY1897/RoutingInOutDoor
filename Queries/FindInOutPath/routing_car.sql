--DROP FUNCTION routing_car(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION routing_car(
    IN from_id  INTEGER,
    IN to_id    INTEGER
) 
RETURNS TABLE(
    dist        DOUBLE PRECISION,
    geom        GEOMETRY) AS 
$BODY$
BEGIN
    RETURN QUERY SELECT ind.dist, ind.path
                FROM indoor_car(from_id, to_id) ind
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT; 