SELECT R.route_desc_id, R.dep_time, R.arr_time, DP.station_id AS d_id, AP.station_id  AS a_id , rdd.seq AS d_seq, rda.seq AS a_seq,
CASE WHEN R.route_desc_id = -2 THEN ST_MakeLine((SELECT DISTINCT geom FROM public."BUS_STATION" bs WHERE bs."stationid" = DP.station_id), (SELECT DISTINCT geom FROM public."BUS_STATION" bs WHERE bs."stationid" = AP.station_id))
ELSE ST_MakeLine(ARRAY(SELECT geom FROM public."BUS_LINK" bl WHERE bl."Route_Id" = R.route_desc_id AND bl."seq" BETWEEN rdd.seq AND rda.seq - 1)) END AS geom																																		   
FROM raptor_find_route(102000091, 30000, 6424) R
	JOIN public.p_st DP
	ON R.dep_st = DP.pseudo_id
	JOIN public.p_st AP
	ON R.arr_st = AP.pseudo_id
	LEFT JOIN public.route_st rdd
	ON rdd.route_desc_id = R.route_desc_id AND rdd.station_id = DP.station_id
	LEFT JOIN public.route_st rda
	ON rda.route_desc_id = R.route_desc_id AND rda.station_id = AP.station_id



--DROP FUNCTION test_raptor(varchar, double precision, double precision,
--                           double precision, double precision);

CREATE OR REPLACE FUNCTION test_raptor(
                IN x1 double precision,
                IN y1 double precision,
                IN x2 double precision,
                IN y2 double precision,
                OUT seq integer,
                OUT geom geometry
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
        EXECUTE 'SELECT "stationid"::integer as id, geom station_id FROM public."BUS_STATION"
                        ORDER BY geom <-> ST_GeometryFromText(''POINT('
                        || x1 || ' ' || y1 || ')'',4326) LIMIT 1' INTO rec;
        source := rec.id;

        EXECUTE 'SELECT "stationid"::integer as id, geom station_id FROM public."BUS_STATION"
                        ORDER BY geom <-> ST_GeometryFromText(''POINT('
                        || x2 || ' ' || y2 || ')'',4326) LIMIT 1' INTO rec;
        target := rec.id;

        -- Shortest path query (TODO: limit extent by BBOX)
        seq := 0;
        sql := 'SELECT R.route_desc_id, R.dep_time, R.arr_time, DP.station_id AS d_id, AP.station_id  AS a_id , rdd.seq AS d_seq, rda.seq AS a_seq,
                CASE WHEN R.route_desc_id = -2 THEN ST_MakeLine((SELECT DISTINCT geom FROM public."BUS_STATION" bs WHERE bs."stationid" = DP.station_id), (SELECT DISTINCT geom FROM public."BUS_STATION" bs WHERE bs."stationid" = AP.station_id))
                ELSE ST_MakeLine(ARRAY(SELECT geom FROM public."BUS_LINK" bl WHERE bl."Route_Id" = R.route_desc_id AND bl."seq" BETWEEN rdd.seq AND rda.seq - 1)) END AS geom																																		   
                FROM raptor_find_route('
                || source || ', 30000, '
                || target
                ||') R
                    JOIN public.p_st DP
                    ON R.dep_st = DP.pseudo_id
                    JOIN public.p_st AP
                    ON R.arr_st = AP.pseudo_id
                    LEFT JOIN public.route_st rdd
                    ON rdd.route_desc_id = R.route_desc_id AND rdd.station_id = DP.station_id
                    LEFT JOIN public.route_st rda
                    ON rda.route_desc_id = R.route_desc_id AND rda.station_id = AP.station_id';

        FOR rec IN EXECUTE sql
        LOOP
                -- Return record
                seq     := seq + 1;
                geom    := rec.geom;
                RETURN NEXT;
        END LOOP;
        RETURN;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT;