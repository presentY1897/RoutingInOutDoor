--DROP FUNCTION test_on_geoserver(DOUBLE PRECISION, DOUBLE PRECISION, INTEGER);

CREATE OR REPLACE FUNCTION test_on_geoserver(   
    IN x1 DOUBLE PRECISION,
    IN y1 DOUBLE PRECISION,
    IN id INTEGER,
    OUT seq INTEGER,
    OUT geom GEOMETRY 
    )
    RETURNS SETOF record AS
$BODY$
DECLARE
        sql     text;
        rec     record;
        source  integer;
        target  integer;
        point   integer;

BEGIN
        -- Find nearest node
        EXECUTE 'SELECT pseudo_id::integer as id, geom FROM p_st
                        ORDER BY geom <-> ST_GeometryFromText(''POINT('
                        || x1 || ' ' || y1 || ')'',4326) LIMIT 1' INTO rec;
        source := rec.id;
        target := id;
        sql := 'SELECT seq, geom FROM find_bus_to_indoor_path(' || source || ', ' || 50009 || ', ' || target || ') ORDER BY seq';

        FOR rec IN EXECUTE sql
        LOOP
                -- Return record
                seq     := rec.seq;
                geom    := rec.geom;
                RETURN NEXT;
        END LOOP;
        RETURN;
END;
$BODY$ 
LANGUAGE 'plpgsql' VOLATILE STRICT; 