-- Table: public.route_st

-- DROP TABLE public.route_st;

CREATE TABLE public.route_st
(
    route_desc_id numeric,
    station_id numeric,
    seq integer,
    section_spd integer,
    dist integer
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.route_st
    OWNER to postgres;

-- Insert
INSERT INTO public.route_st(
	route_desc_id, station_id, seq, section_spd, dist)
	VALUES (?, ?, ?, ?, ?);

-- Insert bus station
INSERT INTO public.route_st(
	route_desc_id, station_id, seq, section_spd, dist)
    SELECT BS."busRouteId", BS."stationid", BS."seq", BS."sectSpd", BS."fullSectDist"
    FROM public."BUS_STATION" BS
        JOIN public."route_desc" rd
        ON BS."busRouteId" = rd."route_desc_id"