--DROP FUNCTION indoor_dijkstra(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION indoor_dijkstra(
                IN source INTEGER,
                IN target INTEGER,
                IN b_id INTEGER,
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

        FOR rec IN SELECT bn.geom, pd.cost
                FROM pgr_dijkstra('
                SELECT link_id::integer AS id,
                         source::integer,
                         target::integer,
                         dist::double precision AS cost
                        FROM building_link
                        WHERE building_id = ' || b_id
                , source -- 시작 노드
                , target -- 도착 노드
                , false, false) pd
                JOIN building_node bn
                ON pd.id1 = bn.node_id
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