-- Table: public.route

-- DROP TABLE public.route;

CREATE TABLE public.route
(
    route_id numeric,
    route_name text,
    route_type integer,
    term integer,
    start_time integer,
    end_time integer,
    p_st_ary integer[],
    geom geometry,
    geom_up geometry,
    geom_down geometry
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.route
    OWNER to postgres;

-- Insert

INSERT INTO public.route(
	route_id, route_name, route_type, term, start_time, end_time, p_st_ary, geom, geom_up, geom_down)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- bus insert

INSERT INTO public.route(
	route_id, route_name, term, route_type, geom, geom_up, geom_down, start_time, end_time, p_st_ary)
	SELECT "Route_Id", "Rout_Name", "term", "routeType", "geom", "geom_up", "geom_down", 14400, 82800, 
    ARRAY(SELECT pseudo_id FROM public.p_st p JOIN public.route_st rs ON p.station_id = rs.station_id WHERE rs.route_desc_id = BR."Route_Id")
	FROM public."BUS_ROUTE" BR
	WHERE "geom" IS NOT NULL

