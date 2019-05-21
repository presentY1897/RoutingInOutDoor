--DROP FUNCTION private_to_in(DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, INTEGER, DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION private_to_in(
    IN x            DOUBLE PRECISION,
    IN y            DOUBLE PRECISION,
    IN building_id  INTEGER,
    IN node_id      INTEGER,
    IN dist_rad         DOUBLE PRECISION,
    OUT seq         INTEGER,
    OUT trip_type   INTEGER,
    OUT geom        GEOMETRY
) 
RETURNS SETOF RECORD AS
$BODY$
DECLARE
    fpoint RECORD;
    rec RECORD;
BEGIN
    SELECT it.gid, ST_SetSRID(ST_MakePoint(x, y), 4326) as geom FROM its_node it ORDER BY ST_Distance(it.geom, ST_SetSRID(ST_MakePoint(x, y), 4326)) LIMIT 1 INTO fpoint;

    SELECT ind.geom AS ingeom, pnd.geom AS pgeom, rp.path AS prvgeom
        FROM find_indoor_exteriors(building_id, node_id) ind,   -- INDOOR PATH
        find_nearest_nodes(building_id, ind.exit_id, dist_rad) pnd, -- PEDESTRIAN PATH
        car_dijkstra(fpoint.gid, pnd.n_id) rp                      -- PRIVATE CAR PATH -- 병목지점
        ORDER BY rp.dist + pnd.dist + ind.dist
        LIMIT 1 INTO rec;

    seq         := 0;
    trip_type   := 1;
    geom        := ST_MakeLine(fpoint.geom, ST_StartPoint(rec.prvgeom));
    RETURN NEXT;
    seq         := 1;
    trip_type   := 1;
    geom        := rec.prvgeom;
    RETURN NEXT;
    seq         := 2;
    trip_type   := -2;
    geom        := rec.pgeom;
    RETURN NEXT;
    seq         := 3;
    trip_type   := 0;
    geom        := rec.ingeom;
    RETURN NEXT;
    RETURN;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT; 