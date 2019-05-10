--DROP FUNCTION car_dijkstra(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION car_dijkstra(
                IN source INTEGER,
                IN target INTEGER,
                OUT path GEOMETRY,
                OUT dist DOUBLE PRECISION
        )
        RETURNS SETOF record AS
$BODY$
DECLARE
        rec     RECORD;
        points  GEOMETRY[];
BEGIN
        dist    := 0;
        path    := NULL::GEOMETRY;

        FOR rec IN SELECT nd.geom, pd.cost
                FROM pgr_dijkstra('
                SELECT gid::integer AS id,
                         source::integer,
                         target::integer,
                         length::double precision AS cost
                        FROM its_link'
                , source -- 시작 노드
                , target -- 도착 노드
                , false, false) pd
                JOIN its_node nd
                ON pd.id1 = nd.gid
        LOOP
                dist    := dist + rec.cost;
                points  := array_append(points, rec.geom);
        END LOOP;
        IF array_length(points, 1) > 0 THEN
            path := ST_MakeLine(points);
            RETURN NEXT;
        END IF;
        RETURN;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT;