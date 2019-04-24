-- Table: public.route_desc

-- DROP TABLE public.route_desc;

CREATE TABLE public.route_desc
(
    route_desc_id numeric,
    route_name text COLLATE pg_catalog."default",
    term integer,
    route_type integer,
    geom geometry,
    geom_up geometry,
    geom_down geometry,
    start_time integer,
    end_time integer
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.route_desc
    OWNER to postgres;

-- Insert

INSERT INTO public.route_desc(
	route_desc_id, route_name, term, route_type, geom, geom_up, geom_down, start_time, end_time)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);

-- bus insert

INSERT INTO public.route_desc(
	route_desc_id, route_name, term, route_type, geom, geom_up, geom_down, start_time, end_time)
	SELECT "Route_Id", "Rout_Name", "term", "routeType", "geom", "geom_up", "geom_down", 14400, 82800
	FROM public."BUS_ROUTE" BR
	WHERE "geom" IS NOT NULL

