-- Table: public.route_station_time

-- DROP TABLE public.route_station_time;

CREATE TABLE public.route_station_time
(
    route_id numeric,
    route_seq integer,
    dep_time integer,
    pseudo_id integer,
    station_seq integer
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.route_station_time
    OWNER to postgres;

-- INSERT
INSERT INTO public.route_station_time(
	route_id, route_seq, dep_time, pseudo_id, station_seq)
	VALUES (?, ?, ?, ?, ?);

INSERT INTO public.route_station_time(
	route_id, route_seq, dep_time, pseudo_id, station_seq)
SELECT rd.route_desc_id as route_desc_id, rt.seq as route_seq, rt.time_series[rs.seq * 2] as dept_time, pt.pseudo_id, rs.seq as station_seq 
FROM public.route_st rs
    JOIN public.route_desc rd
    ON rs.route_desc_id = rd.route_desc_id
    JOIN public.route_time rt
    ON rs.route_desc_id = rt.route_desc_id
    JOIN public.p_st pt
    ON pt.station_id = rs.station_id
ORDER BY pt.pseudo_id, rt.seq, rt.time_series[rs.seq * 2], rs.seq