--DROP FUNCTION public_to_in(DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, INTEGER, DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION public_to_in(
    IN x            DOUBLE PRECISION,
    IN y            DOUBLE PRECISION,
    IN building_id  INTEGER,
    IN node_id      INTEGER,
    IN dist_rad     DOUBLE PRECISION,
    OUT seq         INTEGER,
    OUT trip_type   INTEGER,
    OUT geom        GEOMETRY
) 
RETURNS SETOF RECORD AS
$BODY$
DECLARE
    rec RECORD;
BEGIN
    SELECT it.pseudo_id FROM p_st it ORDER BY ST_Distance(it.geom, ST_SetSRID(ST_MakePoint(x, y), 4326)) LIMIT 1 INTO rec; 
    SELECT rp.path, rp.dist as dist, rp.arr_st_id
    FROM public_dijkstra(
            rec.pseudo_id, 
            50000,
            ARRAY(SELECT DISTINCT pnd.station_id
                FROM find_indoor_exteriors(building_id, node_id) ind,
                find_nearest_stations(building_id, ind.exit_id, dist_rad) pnd
                )
            ) rp
    INTO rec;

    SELECT ind.geom AS ingeom, pnd.geom AS pgeom, rec.path AS prvgeom
        FROM find_indoor_exteriors(building_id, node_id) ind,   -- INDOOR PATH
        find_nearest_stations(building_id, ind.exit_id, dist_rad) pnd  -- PEDESTRIAN PATH      
        WHERE pnd.station_id = rec.arr_st_id
        ORDER BY pnd.dist + rec.dist + ind.dist
        LIMIT 1 INTO rec;

    seq         := 0;
    trip_type   := 2;
    geom        := rec.prvgeom;
    RETURN NEXT;
    seq         := 1;
    trip_type   := -2;
    geom        := rec.pgeom;
    RETURN NEXT;
    seq         := 2;
    trip_type   := 0;
    geom        := rec.ingeom;
    RETURN NEXT;
    RETURN;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT; 