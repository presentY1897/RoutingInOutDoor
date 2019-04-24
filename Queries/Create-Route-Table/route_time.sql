--DROP FUNCTION create_route_timetable;

CREATE OR REPLACE FUNCTION create_route_timetable(
    IN id NUMERIC,
	OUT route_desc_id NUMERIC,
	OUT seq INTEGER,
    OUT time_series INTEGER []
) 
RETURNS SETOF RECORD AS 
$BODY$
DECLARE
	sql TEXT;
	rec RECORD;
    st_rec RECORD;
    t INTEGER;
    last_time INTEGER;
    sect_dur INTEGER;
BEGIN
	FOR rec IN SELECT rd.route_desc_id, term, start_time, end_time FROM public.route_desc rd WHERE rd.route_desc_id = id
	LOOP
		route_desc_id := rec.route_desc_id;
        t := rec.start_time;
        seq := 0;
        WHILE t <= rec.end_time 
        LOOP
            last_time := t;
            time_series := '{}';

            FOR st_rec IN SELECT rs.dist, section_spd / 0.36 as sect_spd, rs.seq FROM public.route_st rs WHERE rs.route_desc_id = rec.route_desc_id ORDER BY rs.seq
            LOOP
                sect_dur := 0;
                IF st_rec.seq = 1 THEN
                    time_series := array_append(time_series, t); --첫차 출발 시간
                ELSE
                    IF st_rec.sect_spd <= 0 THEN
                        sect_dur := 15;
                    ELSE
                        sect_dur := st_rec.dist / st_rec.sect_spd;
                    END IF;

                    IF sect_dur < 10 THEN -- 차량 대기 시간 10초보다 다음 정류장 도착이 더 빠를 경우
                        last_time := last_time + 5;
                    ELSE
                        last_time := last_time + 10;
                    END IF;

                    time_series := array_append(time_series,  CAST(last_time as INTEGER)); -- 앞 정류장에서 출발 시간

                    last_time := last_time + sect_dur; -- 차량 이동 시간 추가
                    time_series := array_append(time_series,  CAST(last_time as INTEGER));
                END IF;
            END LOOP;

            seq := seq + 1;
            RETURN NEXT;
            t := rec.start_time + seq * rec.term * 60;
        END LOOP;	
	END LOOP;
	RETURN;
END;
$BODY$ 
LANGUAGE 'plpgsql';

SELECT * FROM create_route_timetable()