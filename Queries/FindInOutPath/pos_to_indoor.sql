--DROP FUNCTION pos_to_indoor(DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION pos_to_indoor(
    IN x DOUBLE PRECISION,
    IN y DOUBLE PRECISION,
    IN building_id INTEGER,
    IN node_id INTEGER,
    IN vehicle_type INTEGER -- 1 car 2 public transit
) 
RETURNS TABLE(
    seq INTEGER,
    trip_type INTEGER,
    geom GEOMETRY) AS 
$BODY$
BEGIN
    IF vehicle_type = 1 THEN
        RETURN QUERY SELECT * FROM private_to_in(x, y, building_id, node_id);
    ELSEIF vehicle_type = 2 THEN
        RETURN QUERY SELECT * FROM public_to_in(x, y, building_id, node_id);
    ELSE
        RETURN QUERY SELECT null::INTEGER, null::INTEGER, null::GEOMETRY;
    END IF;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT; 