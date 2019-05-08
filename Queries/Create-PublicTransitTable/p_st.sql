-- Table: public.p_st

-- DROP TABLE public.p_st;

CREATE TABLE public.p_st
(
    station_id numeric,
    pseudo_id integer,
    geom geometry
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.p_st
    OWNER to postgres;

-- INSERT
INSERT INTO public.p_st(
	station_id, pseudo_id, geom)
	VALUES (?, ?, ?);