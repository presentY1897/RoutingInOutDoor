-- 확인
SELECT ST_SetSRID(ST_MakeLine(ARRAY(SELECT geom FROM public."BUS_NODE" ND WHERE ND."Route_Id" = RO."Route_Id" ORDER BY ND."Seq")), 4326)
FROM public."BUS_ROUTE" RO

-- 노선 geometry 입력
UPDATE public."BUS_ROUTE" RO
SET geom = ST_SetSRID(ST_MakeLine(ARRAY(SELECT geom FROM public."BUS_NODE" ND WHERE ND."Route_Id" = RO."Route_Id" ORDER BY ND."Seq")), 4326)

-- 상하행 노선 형상 확인용
SELECT ST_GeometryN(ST_Split(ST_Snap(RO.geom, ST_ClosestPoint(RO.geom, ST.geom), 1), ST_ClosestPoint(RO.geom, ST.geom)), 1),
	   ST_GeometryN(ST_Split(ST_Snap(RO.geom, ST_ClosestPoint(RO.geom, ST.geom), 1), ST_ClosestPoint(RO.geom, ST.geom)), 2)
FROM public."BUS_ROUTE" RO
	JOIN (SELECT "Route_Id", geom FROM public."BUS_STATION" ST 
        JOIN (SELECT DISTINCT "busRouteId" as "Route_Id", "trnstnid" FROM public."BUS_STATION") A 
        ON A."Route_Id" = ST."busRouteId" AND A."trnstnid" = ST."stationid") ST
	ON RO."Route_Id" = ST."Route_Id"
LIMIT 10

-- 노선 형상 상하행 입력
UPDATE public."BUS_ROUTE" II
SET geom_up = ST_GeometryN(ST_Split(ST_Snap(RO.geom, ST_ClosestPoint(RO.geom, ST.geom), 1), ST_ClosestPoint(RO.geom, ST.geom)), 1),
    geom_down =  ST_GeometryN(ST_Split(ST_Snap(RO.geom, ST_ClosestPoint(RO.geom, ST.geom), 1), ST_ClosestPoint(RO.geom, ST.geom)), 2)
FROM public."BUS_ROUTE" RO
	JOIN (SELECT "Route_Id", geom FROM public."BUS_STATION" ST 
        JOIN (SELECT DISTINCT "busRouteId" as "Route_Id", "trnstnid" FROM public."BUS_STATION") A 
        ON A."Route_Id" = ST."busRouteId" AND A."trnstnid" = ST."stationid") ST
	ON RO."Route_Id" = ST."Route_Id"
WHERE II."Route_Id" = RO."Route_Id"