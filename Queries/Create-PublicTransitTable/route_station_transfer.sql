-- Table: public.station_transfer

-- DROP TABLE public.station_transfer;
CREATE TABLE public.station_transfer
(
    f_id integer,
    e_id integer,
    dist double precision
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.station_transfer
    OWNER to postgres;

-- INSERT
INSERT INTO public.station_transfer(
f_id, e_id, dist)
VALUES (?, ?, ?);

-- INSERT 700m Transfer
INSERT INTO public.station_transfer(
f_id, e_id, dist)
SELECT A.pseudo_id, B.pseudo_id, ST_Distance(ST_Transform(A.geom, 3857), ST_Transform(B.geom, 3857))
FROM (SELECT DISTINCT pt.*, rs.geom
FROM public.p_st pt
JOIN public."BUS_STATION" rs
ON rs."stationid" = pt.station_id) A
JOIN (SELECT DISTINCT pt.*, rs.geom
FROM public.p_st pt
JOIN public."BUS_STATION" rs
ON rs."stationid" = pt.station_id) B
ON A.station_id <> B.station_id AND ST_Distance(ST_Transform(A.geom, 3857), ST_Transform(B.geom, 3857)) < 700