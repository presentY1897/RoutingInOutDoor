--- Station과 가장 밀접한 Node 탐색


-- 우선 회차 정류장이 타당하다고 가정하고 회차정류장의 노드를 탐색
-- 노선별 회차 정류장
SELECT DISTINCT "busRouteId", "trnstnid" FROM public."BUS_STATION" TRST
-- 노선별 회차 정류장의 최근접 노드
SELECT (SELECT public."BUS_NODE"."Seq"::integer AS id FROM public."BUS_NODE"
                        WHERE "Route_Id" =  ST."busRouteId"
                        ORDER BY geom <-> ST."geom" LIMIT 2), ST.*
FROM public."BUS_STATION" AS ST
JOIN (SELECT DISTINCT "busRouteId", "trnstnid" FROM public."BUS_STATION") TRST
ON ST."busRouteId" = TRST."busRouteId" AND ST."stationid" = TRST."trnstnid"
ORDER BY ST."busRouteId"


SELECT pg_nearestId(public."BUS_NODE", ST."busRouteId", ST."geom"), ST.*
FROM public."BUS_STATION" AS ST
JOIN (SELECT DISTINCT "busRouteId", "trnstnid" FROM public."BUS_STATION") TRST
ON ST."busRouteId" = TRST."busRouteId" AND ST."stationid" = TRST."trnstnid"
ORDER BY ST."busRouteId"