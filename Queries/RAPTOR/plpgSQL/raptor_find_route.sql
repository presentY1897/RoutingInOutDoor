--DROP FUNCTION raptor_find_route;

CREATE OR REPLACE FUNCTION raptor_find_route(
    IN start_station_id NUMERIC,
    IN start_time INTEGER,
    IN end_station_id NUMERIC,
    OUT route_id NUMERIC,
    OUT route_seq INTEGER,
    OUT dep_st NUMERIC,
    OUT arr_st NUMERIC,
    OUT dep_time INTEGER,
    OUT arr_time INTEGER,
    OUT path_seq DOUBLE PRECISION
) 
RETURNS SETOF RECORD AS 
$BODY$
DECLARE
    deps trip[];
    Q tripQ[];
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
    marked_stop := '{}';
    Q := '{}';
    EXECUTE 'SELECT pseudo_id FROM public.p_st WHERE station_id = ' || start_station_id INTO rec;
    start_station_id := rec.pseudo_id;
    EXECUTE 'SELECT pseudo_id FROM public.p_st WHERE station_id = ' || end_station_id INTO rec;
    end_station_id := rec.pseudo_id;
    marked_stop := array_append(marked_stop, CAST(start_station_id AS INTEGER)); -- 시작 정류장 마킹
    -- 도착 시간 초기화
    deps := array_fill(create_trip(-1, -1, -1, -1, 900000, 0), ARRAY[20000]);
    deps[marked_stop[1]] := create_trip(-1, -1, marked_stop[1], -1, start_time, 0); -- 첫 정류장 트립 초기화

    k := 1;
    FOR k in 1..2 -- k 반복
    LOOP
        marked_stop_t := '{}'; -- 해집합 초기화

        FOREACH new_stop IN ARRAY marked_stop
        LOOP
            rec_sql := 'SELECT f_id, e_id, dist / 1.2 as dur FROM public.station_transfer WHERE f_id = '
                    || new_stop;
            FOR rec IN EXECUTE rec_sql
            LOOP
                IF deps[new_stop].arr_time + rec.dur < deps[rec.e_id].arr_time THEN
                    --dep_times[rec.p_st_ary[seq]] := rec.time_series[seq * 2 - 1];
                    deps[rec.e_id] := create_trip(-2, new_stop, rec.e_id, deps[rec.f_id].arr_time, CAST(deps[rec.f_id].arr_time + rec.dur as INTEGER), CAST(k as DOUBLE PRECISION) - 0.5);
                    marked_stop_t := array_remove(marked_stop_t, rec.e_id);
                    marked_stop_t := array_append(marked_stop_t, rec.e_id);
                END IF;
            END LOOP;
        END LOOP;

        marked_stop := marked_stop_t;

        FOREACH new_stop IN ARRAY marked_stop
        LOOP
            rec_sql := 'SELECT DISTINCT ON (route_id) route_id, route_seq, dept_time, pseudo_id, station_seq
                    FROM public.route_station_time
                    WHERE pseudo_id = '
                    || new_stop || ' AND dept_time > ' || deps[new_stop].arr_time
                    || ' ORDER BY route_id, route_seq';
            FOR rec IN EXECUTE rec_sql
            LOOP
                SELECT * FROM UNNEST(Q) as t WHERE t.route_id = rec.route_id INTO recs;
                IF recs IS NOT NULL THEN
                    -- IF (SELECT station_seq FROM UNNEST(Q) as t WHERE t.route_id = rec.route_id) > rec.station_seq THEN
                       -- Q := array_remove(Q, create_tripQ(recs.route_id, recs.route_seq, recs.dept_time, recs.pseudo_id, recs.station_seq));
                       -- Q := array_append(Q, create_tripQ(rec.route_id, rec.route_seq, rec.dept_time, rec.pseudo_id, rec.station_seq));
                    -- END IF;
                ELSE
                    Q := array_append(Q, create_tripQ(rec.route_id, rec.route_seq, rec.dept_time, rec.pseudo_id, rec.station_seq));
                END IF;
            END LOOP;
        END LOOP;

        FOREACH recs IN ARRAY Q
        LOOP
            rec_sql := 'SELECT rt.route_id, rt.time_series as times, rd.p_st_ary as stations, array_length(p_st_ary, 1) as maxseq
                    FROM public.route_time rt
                    JOIN public.route_desc rd
                    ON rt.route_id = rd.route_id
                    WHERE rt.route_id = '
                    || recs.route_id || ' AND rt.seq > ' || recs.route_seq;
            seq := recs.station_seq + 1;
            
            FOR rec IN EXECUTE rec_sql
            LOOP
                FOR seq IN seq..rec.maxseq - 1
                LOOP
                    IF rec.times[seq * 2 - 1] < deps[rec.stations[seq]].arr_time THEN
                        deps[rec.stations[seq]] := create_trip(rec.route_id, rec.stations[recs.station_seq], rec.stations[seq], rec.times[seq * 2], rec.times[seq * 2 - 1], CAST(k as DOUBLE PRECISION));
                        marked_stop := array_remove(marked_stop, rec.stations[seq]);
                        marked_stop := array_append(marked_stop, rec.stations[seq]);
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;

        Q := '{}';

        FOREACH new_stop IN ARRAY marked_stop
        LOOP
            rec_sql := 'SELECT f_id, e_id, dist / 1.2 as dur FROM public.station_transfer WHERE f_id = '
                    || new_stop;
            FOR rec IN EXECUTE rec_sql
            LOOP
                IF deps[new_stop].arr_time + rec.dur < deps[rec.e_id].arr_time THEN
                    --dep_times[rec.p_st_ary[seq]] := rec.time_series[seq * 2 - 1];
                    deps[rec.e_id] := create_trip(-2, new_stop, rec.e_id, deps[rec.f_id].arr_time, CAST(deps[rec.f_id].arr_time + rec.dur as INTEGER), CAST(k as DOUBLE PRECISION) + 0.5);
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
    seq := 0;
    new_stop := end_station_id;
    WHILE new_stop != start_station_id 
    LOOP
        route_id := deps[new_stop].route_id;
        route_seq := 0;
        dep_st := deps[new_stop].dep_st;
        arr_st := deps[new_stop].arr_st;
        dep_time := deps[new_stop].dep_time;
        arr_time := deps[new_stop].arr_time;
        path_seq := seq;
        new_stop := deps[new_stop].dep_st;
        seq := seq + 1;
        RETURN NEXT;
    END LOOP;
    route_id := deps[new_stop].route_id;
    route_seq := 0;
    dep_st := deps[new_stop].dep_st;
    arr_st := deps[new_stop].arr_st;
    dep_time := deps[new_stop].dep_time;
    arr_time := deps[new_stop].arr_time;
    path_seq := seq;
    new_stop := deps[new_stop].dep_st;
    -- FOREACH rec IN ARRAY deps
    -- LOOP
    --     route_id := rec.route_id;
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