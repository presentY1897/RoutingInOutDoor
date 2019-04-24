---- 바보였다. 회차지 컬럼이 있었다. trnstnid
---반환 정류장 찾기
SELECT *
FROM (
SELECT *, LEAD("direction") over (partition by "busRouteId" order by "busRouteId", "seq" ) AS next_direction FROM public."BUS_STATION" ST
ORDER BY "busRouteId", "seq") A
WHERE A."direction" <> A."next_direction"
ORDER BY "busRouteId", "seq"a

--- 반환 정류장 중첩 찾기
SELECT A."busRouteId", COUNT(*) as check
FROM (
SELECT *, LEAD("direction") over (partition by "busRouteId" order by "busRouteId", "seq" ) AS next_direction FROM public."BUS_STATION" ST
ORDER BY "busRouteId", "seq") A
WHERE A."direction" <> A."next_direction"
GROUP BY A."busRouteId"
ORDER BY COUNT(*) desc