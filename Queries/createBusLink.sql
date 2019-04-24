--링크 삭제
DELETE FROM public."BUS_LINK"

--상행
SELECT P.fsid, P.esid, P.routeid, ST_GeometryN(ST_Split(ST_Snap(P.geom, ST_ClosestPoint(P.geom, P.egeom), 1), ST_ClosestPoint(P.geom, P.egeom)), 1) as "firstGeom",
P.seq as "seq"
FROM (
SELECT FS."stationid" as fsid, LEAD(FS."stationid") OVER (PARTITION BY FS."busRouteId" ORDER BY FS."seq") as esid, FS."busRouteId" as "routeid",
LEAD(FS."geom") OVER (PARTITION BY FS."busRouteId" ORDER BY FS."seq") as egeom,
ST_GeometryN(ST_Split(ST_Snap(RO.geom, ST_ClosestPoint(RO.geom, FS.geom), 1), ST_ClosestPoint(RO.geom, FS.geom)), 2) as geom,
FS."seq" as seq
FROM public."BUS_STATION" FS
JOIN public."BUS_STATION" TR
ON FS."trnstnid" = TR."stationid" AND FS."busRouteId" = TR."busRouteId"
JOIN (SELECT geom_up as geom , "Route_Id" FROM public."BUS_ROUTE") RO
ON FS."busRouteId" = RO."Route_Id"
WHERE FS."seq" <= TR."seq" -- 회차지 정류장 이전의 정류장 순번들
) P
WHERE esid IS NOT NULL -- 마지막 NULL로 생성되는 링크 제외
ORDER BY routeid, "seq"


-- 상행 입력
INSERT INTO public."BUS_LINK"(
	"From_Id", "End_Id", "Route_Id", geom, seq)
    SELECT P.fsid, P.esid, P.routeid, ST_LineSubstring(P.gline, 
    CASE WHEN P.floc < 0 OR P.floc > 1 THEN 0 ELSE P.floc END, 
    CASE WHEN P.eloc < 0 OR P.eloc > 1 THEN 1 ELSE p.eloc END),
    P.seq as "seq"
    FROM (
        SELECT FS."stationid" as fsid, LEAD(FS."stationid") OVER (PARTITION BY FS."busRouteId" ORDER BY FS."seq") as esid, FS."busRouteId" as "routeid",
        ST_LineLocatePoint(RO.geom, ST_ClosestPoint(RO.geom, FS.geom)) as floc,
        ST_LineLocatePoint(RO.geom, ST_ClosestPoint(RO.geom, LEAD(FS."geom") OVER (PARTITION BY FS."busRouteId" ORDER BY FS."seq"))) as eloc,
        RO.geom as gline,
        FS."seq" as seq
        FROM public."BUS_STATION" FS
        JOIN public."BUS_STATION" TR
        ON FS."trnstnid" = TR."stationid" AND FS."busRouteId" = TR."busRouteId"
        JOIN (SELECT geom_up as geom , "Route_Id" FROM public."BUS_ROUTE") RO
        ON FS."busRouteId" = RO."Route_Id"
        WHERE FS."seq" <= TR."seq" -- 회차지 정류장 이전의 정류장 순번들
    ) P
    WHERE esid IS NOT NULL -- 마지막 NULL로 생성되는 링크 제외  
    AND floc < eloc
    ORDER BY routeid, "seq"

-- 하행 입력
INSERT INTO public."BUS_LINK"(
	"From_Id", "End_Id", "Route_Id", geom, seq)
    SELECT P.fsid, P.esid, P.routeid, ST_LineSubstring(P.gline, 
    CASE WHEN P.floc < 0 OR P.floc > 1 THEN 0 ELSE P.floc END, 
    CASE WHEN P.eloc < 0 OR P.eloc > 1 THEN 1 ELSE p.eloc END),
    P.seq as "seq"
    FROM (
    SELECT FS."stationid" as fsid, LEAD(FS."stationid") OVER (PARTITION BY FS."busRouteId" ORDER BY FS."seq") as esid, FS."busRouteId" as "routeid",
    ST_LineLocatePoint(RO.geom, ST_ClosestPoint(RO.geom, FS.geom)) as floc,
    ST_LineLocatePoint(RO.geom, ST_ClosestPoint(RO.geom, LEAD(FS."geom") OVER (PARTITION BY FS."busRouteId" ORDER BY FS."seq"))) as eloc,
    RO.geom as gline,
    FS."seq" as seq
    FROM public."BUS_STATION" FS
    JOIN public."BUS_STATION" TR
    ON FS."trnstnid" = TR."stationid" AND FS."busRouteId" = TR."busRouteId"
    JOIN (SELECT geom_down as geom , "Route_Id" FROM public."BUS_ROUTE") RO
    ON FS."busRouteId" = RO."Route_Id"
    WHERE FS."seq" >= TR."seq" -- 회차지 정류장 이후의 정류장 순번들
    ) P
    WHERE esid IS NOT NULL -- 마지막 NULL로 생성되는 링크 제외  
    AND floc < eloc
    ORDER BY routeid, "seq"

-- LOOP 돌면서 전체 geom 잘라가기 실패
CREATE OR REPLACE FUNCTION cut_link(
    OUT fsid numeric,
    OUT esid numeric,
    OUT routeid numeric,
    OUT geom geometry,
    OUT seq integer
)
RETURNS SETOF record AS 
$BODY$
DECLARE
    rec RECORD;
    routeRec RECORD;
    tempGeom GEOMETRY;
    i INTEGER;
    pastStationId NUMERIC;
    routeQuery TEXT;
    sql TEXT;
BEGIN
    -- Find Routes
    routeQuery := 'SELECT distinct "Route_Id" as id FROM public."BUS_ROUTE"';
    FOR routeRec IN EXECUTE routeQuery
    LOOP
    EXECUTE 'SELECT geom_up as geom FROM public."BUS_ROUTE" WHERE "Route_Id" = ' || routeRec.id INTO rec;
    tempGeom := rec.geom;
    sql := '
        SELECT FS."stationid" as fsid,
        FS."seq" as seq,
        FS."geom" as sgeom
        FROM public."BUS_STATION" FS
        JOIN public."BUS_STATION" TR
        ON FS."trnstnid" = TR."stationid" AND FS."busRouteId" = TR."busRouteId"
        WHERE FS."seq" < TR."seq" AND FS."busRouteId" = ' || routeRec.id; -- 회차지 전까지의 정류장들

    i := 0;
        FOR rec IN EXECUTE sql
        LOOP
            IF (i != 0) THEN 
            -- 두개로 자르기
            EXECUTE 'SELECT ST_Split(ST_Snap(' || tempGeom::geography
            || ', ST_ClosestPoint(' || tempGeom::geography || ', ' || rec.sgeom::geography
            || '), 1), ST_ClosestPoint(' || tempGeom::geography ||', ' || rec.sgeom::geography
            || ')) as geom' INTO tempGeom;
            EXECUTE 'SELECT ST_GeometryN(' || tempGeom.geom::geography || ', 1) as geom' INTO rec; -- 링크 geometry
            EXECUTE 'SELECT ST_GeometryN(' || tempGeom.geom::geography || ', 2) as geom' INTO tempGeom; -- 남은 노선 geometry

            fsid := pastStationId;
            esid := rec.fsid;
            routeid := routeRec.id;
            geom := rec.geom;
            seq := rec.seq - 1;
            RETURN NEXT;
            END IF;

            pastStationId := rec.fsid;
            i := i + 1;
        END LOOP;
    END LOOP;
    RETURN;
END;
$BODY$ LANGUAGE 'plpgsql' VOLATILE STRICT;