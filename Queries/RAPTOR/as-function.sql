--DROP FUNCTION raptor_find_route;

CREATE OR REPLACE FUNCTION raptor_find_route(
    IN start_station_id NUMERIC,
    IN start_time INTEGER,
    IN end_station_id NUMERIC,
    OUT route_desc_id NUMERIC,
    OUT route_seq INTEGER,
    OUT dep_st NUMERIC,
    OUT arr_st NUMERIC,
    OUT dep_time INTEGER,
    OUT arr_time INTEGER,
    OUT path_seq INTEGER
) 
RETURNS SETOF RECORD AS 
$BODY$
DECLARE
    dep_times INTEGER[];
    deps trip[];
    Q trip[];
    marked_stop INTEGER[];
    marked_stop_t INTEGER[];
    k INTEGER;
    new_stop INTEGER;
    rec RECORD;
    recs RECORD;
    rec_sql TEXT;
    seq INTEGER;
BEGIN
    marked_stop_t := '{}';
    EXECUTE 'SELECT pseudo_id FROM public.p_st WHERE station_id = ' || start_station_id INTO rec;
    start_station_id := rec.pseudo_id;
    marked_stop := array_append(marked_stop, rec.pseudo_id); -- 시작 정류장 마킹
    -- 도착 시간 초기화
    dep_times := array_fill(900000, ARRAY[20000]);
    deps := array_fill(create_trip(-1, -1, -1, -1, 900000), ARRAY[20000]);
    dep_times[marked_stop[1]] := start_time; -- 첫 정류장 시작 시간 초기화
    deps[marked_stop[1]] := create_trip(-1, -1, marked_stop[1], -1, start_time); -- 첫 정류장 트립 초기화

    k := 1;
    FOR k in 1..2 -- k 반복
    LOOP
        Q := '{}'; -- 해집합 초기화
        marked_stop_t := '{}';
        FOREACH new_stop IN ARRAY marked_stop
        LOOP
            rec_sql := 'SELECT DISTINCT ON (rt.route_desc_id) st.route_desc_id as route_desc_id, st.seq as rseq, rt.time_series, rd.p_st_ary,
                    (SELECT MAX(seq) FROM public.route_st WHERE st.route_desc_id = route_desc_id GROUP BY route_desc_id) as maxseq 
                    FROM public.route_st st
                        JOIN public.route_time rt
                        ON st.route_desc_id = rt.route_desc_id
                        JOIN public.route_desc rd
                        ON st.route_desc_id = rd.route_desc_id
                    WHERE station_id = (SELECT station_id FROM public.p_st WHERE pseudo_id = '
                    || new_stop || ') AND rt.time_series[st.seq * 2 - 1] > ' || deps[new_stop].arr_time
                    || ' ORDER BY rt.route_desc_id, rt.seq';
            FOR rec IN EXECUTE rec_sql
            LOOP
                seq := rec.rseq + 1;
                FOR seq IN seq..rec.maxseq - 1
                LOOP
                    -- Q := array_append(Q, create_trip(rec.route_desc_id, new_stop, rec.p_st_ary[seq], rec.time_series[rec.rseq * 2], rec.time_series[seq * 2 - 1]));
                    -- IF rec.time_series[seq * 2 - 1] < dep_times[rec.p_st_ary[seq]] THEN
                    IF rec.time_series[seq * 2 - 1] < deps[rec.p_st_ary[seq]].arr_time THEN
                        --dep_times[rec.p_st_ary[seq]] := rec.time_series[seq * 2 - 1];
                        deps[rec.p_st_ary[seq]] := create_trip(rec.route_desc_id, new_stop, rec.p_st_ary[seq], rec.time_series[rec.rseq * 2], rec.time_series[seq * 2 - 1]);
                        marked_stop_t := array_remove(marked_stop_t, rec.p_st_ary[seq]);
                        marked_stop_t := array_append(marked_stop_t, rec.p_st_ary[seq]);
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;

        marked_stop := marked_stop_t;

        FOREACH new_stop IN ARRAY marked_stop
        LOOP
            rec_sql := 'SELECT f_id, e_id, dist / 1.2 as dur FROM public.station_transfer WHERE f_id = '
                    || new_stop;
            FOR rec IN EXECUTE rec_sql
            LOOP
                IF deps[new_stop].arr_time + rec.dur < deps[rec.e_id].arr_time THEN
                    --dep_times[rec.p_st_ary[seq]] := rec.time_series[seq * 2 - 1];
                    deps[rec.e_id] := create_trip(-2, new_stop, rec.e_id, deps[rec.f_id].arr_time, CAST(deps[rec.f_id].arr_time + rec.dur as INTEGER));
                    marked_stop_t := array_remove(marked_stop_t, rec.e_id);
                    marked_stop_t := array_append(marked_stop_t, rec.e_id);
                END IF;
            END LOOP;
        END LOOP;
        -- marked_stop := '{}';
        -- FOREACH rec IN ARRAY Q
        -- LOOP
        --     IF rec.arr_time < dep_times[rec.arr_st] THEN
        --         dep_times[rec.arr_st] := rec.arr_time;
        --         deps[rec.arr_st] := rec;
        --         marked_stop := array_remove(marked_stop, rec.arr_st);
        --         marked_stop := array_append(marked_stop, rec.arr_st);
        --     END IF;
        -- END LOOP;
        marked_stop := marked_stop_t;

        -- IF array_length(marked_stop, 1) = 0 THEN
        --     EXIT;
        -- END IF;
    END LOOP;

    new_stop := end_station_id;
    WHILE new_stop <> start_station_id 
    LOOP
        route_desc_id := deps[new_stop].route_desc_id;
        route_seq := 0;
        dep_st := deps[new_stop].dep_st;
        arr_st := deps[new_stop].arr_st;
        dep_time := deps[new_stop].dep_time;
        arr_time := deps[new_stop].arr_time;
        path_seq := 0;
        new_stop := deps[new_stop].dep_st;
        RETURN NEXT;
    END LOOP;
    route_desc_id := deps[new_stop].route_desc_id;
    route_seq := 0;
    dep_st := deps[new_stop].dep_st;
    arr_st := deps[new_stop].arr_st;
    dep_time := deps[new_stop].dep_time;
    arr_time := deps[new_stop].arr_time;
    path_seq := 0;
    new_stop := deps[new_stop].dep_st;
    -- FOREACH rec IN ARRAY deps
    -- LOOP
    --     route_desc_id := rec.route_desc_id;
    --     route_seq := 0;
    --     dep_st := rec.dep_st;
    --     arr_st := rec.arr_st;
    --     dep_time := rec.dep_time;
    --     arr_time := rec.arr_time;
    --     path_seq := 0;
    --     RETURN NEXT;
    -- END LOOP;
    RETURN;
END;
$BODY$ 
LANGUAGE 'plpgsql' VOLATILE STRICT;