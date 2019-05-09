
-------------------------------------------------------------
-- create database
-------------------------------------------------------------
CREATE DATABASE inout;

CREATE EXTENSION postgis;
CREATE EXTENSION pgrouting;
CREATE EXTENSION dblink;

-------------------------------------------------------------
-- create table
-------------------------------------------------------------
-- public transit
select dblink_connect('dblink-outdoor','hostaddr=127.0.0.1 port=5432 dbname=OutDoor user=postgres password='); -- dblink

-- route
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

INSERT INTO public.route(
	route_id, route_name, route_type, term, start_time, end_time, p_st_ary, geom, geom_up, geom_down)
	SELECT * FROM dblink('dblink-outdoor', 'SELECT route_desc_id, route_name, route_type, term, start_time, end_time, p_st_ary, geom, geom_up, geom_down
	FROM public.route_desc') AS outdoor (route_desc_id NUMERIC, route_name TEXT, route_type INTEGER, term INTEGER, start_time INTEGER, end_time INTEGER, p_st_ary INTEGER[], geom GEOMETRY, geom_up GEOMETRY, geom_down GEOMETRY);

-- route_st
CREATE TABLE public.route_st
(
    route_id numeric,
    station_id numeric,
    seq integer,
    section_spd integer,
    dist integer
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.route_st
    OWNER to postgres;

INSERT INTO public.route_st(
	route_id, station_id, seq, section_spd, dist)
	SELECT * FROM dblink('dblink-outdoor', 'SELECT route_desc_id, station_id, seq, section_spd, dist
	FROM public.route_st;') AS outdoor (route_desc_id NUMERIC, station_id NUMERIC, seq INTEGER, section_spd INTEGER, dist INTEGER);

-- route_station_time
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

INSERT INTO public.route_station_time(
	route_id, route_seq, dep_time, pseudo_id, station_seq)
	SELECT * FROM dblink('dblink-outdoor', 'SELECT route_desc_id, route_seq, dept_time, pseudo_id, station_seq
	FROM public.route_station_time;') AS outdoor (route_desc_id NUMERIC, route_seq INTEGER, dept_time INTEGER, pseudo_id INTEGER, station_seq INTEGER);

-- p_st
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

INSERT INTO public.p_st(
	station_id, pseudo_id, geom)
	SELECT * FROM dblink('dblink-outdoor', 'SELECT DISTINCT station_id, pseudo_id, geom
	FROM public.p_st pst
	JOIN public."BUS_STATION" bs
	ON pst.station_id = bs."stationid";') AS outdoor (station_id NUMERIC, pseudo_id INTEGER, geom GEOMETRY);

-- station_transfer
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

INSERT INTO public.station_transfer(
f_id, e_id, dist)
	SELECT * FROM dblink('dblink-outdoor', 'SELECT f_id, e_id, dist
	FROM public.station_transfer;') AS outdoor (f_id INTEGER, e_id INTEGER, dist DOUBLE PRECISION);

-- route_link
CREATE TABLE public.route_link
(
    link_id integer,
    route_id numeric,
    f_id integer,
    e_id integer,
    seq integer,
    geom geometry
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.route_link
    OWNER to postgres;

INSERT INTO public.route_link(
	link_id, route_id, f_id, e_id, seq, geom)
	SELECT * FROM dblink('dblink-outdoor', 'SELECT "Link_Id", "Route_Id", "From_Id", "End_Id", seq, geom
	FROM public."BUS_LINK";') AS outdoor (link_id INTEGER, route_id NUMERIC, f_id INTEGER, e_id INTEGER, seq INTEGER, geom GEOMETRY);

-- route_time
CREATE TABLE public.route_time
(
    route_id numeric,
    seq integer,
    time_series integer[]
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.route_time
    OWNER to postgres;

INSERT INTO public.route_time(
	route_id, seq, time_series)
	SELECT * FROM dblink('dblink-outdoor', 'SELECT route_desc_id, seq, time_series
	FROM public.route_time;') AS outdoor (
    route_id numeric,
    seq integer,
    time_series integer[]);

-- its
select dblink_connect('dblink-its','hostaddr=127.0.0.1 port=5432 dbname=its_sample user=postgres password='); -- dblink

-- its_node
CREATE TABLE public.its_node
(
    gid integer,
    node_id character varying(10),
    node_name character varying(44),
    geom geometry
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.its_node
    OWNER to postgres;

INSERT INTO public.its_node(
	gid, node_id, node_name, geom)
	SELECT * FROM dblink('dblink-its', 'SELECT gid, node_id, node_name, geom
	FROM public.node;') AS outdoor (gid INTEGER, node_id CHARACTER VARYING(10), node_name CHARACTER VARYING(44), geom GEOMETRY );

-- its_link
CREATE TABLE public.its_link
(
    gid integer,
    link_id character varying(10),
    f_node character varying(10),
    t_node character varying(10),
    road_name character varying(44),
    source integer,
    target integer,
    length double precision,
    geom geometry
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.its_link
    OWNER to postgres;

INSERT INTO public.its_link(
	gid, link_id, f_node, t_node, road_name, source, target, length, geom)
	SELECT * FROM dblink('dblink-its', 'SELECT gid, link_id, f_node, t_node, road_name, source, target, length, geom
	FROM public.link;') AS outdoor (gid INTEGER, link_id CHARACTER VARYING(10), f_node CHARACTER VARYING(10), t_node CHARACTER VARYING(10), road_name CHARACTER VARYING(44), source INTEGER, target INTEGER, length DOUBLE PRECISION, geom GEOMETRY);
    
-- building
select dblink_connect('dblink-indoor','hostaddr=127.0.0.1 port=5432 dbname=InDoor user=postgres password='); -- dblink

--building
CREATE TABLE public.building
(
    building_id integer,
    building_name text
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.building
    OWNER to postgres;

INSERT INTO public.building(
	building_id, building_name)
	VALUES (1, "제주 박물관");

-- building_node
CREATE TABLE public.building_node
(
    building_id integer,
    node_id integer,
    node_name text,
    node_type integer,
    floor double precision,
    exterior boolean,
    geom geometry
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.building_node
    OWNER to postgres;

INSERT INTO public.building_node(
	building_id, node_id, node_name, node_type, floor, exterior, geom)
	SELECT * FROM dblink('dblink-indoor', 'SELECT 1 AS building_id, gid, name, 0 AS type, floor, exterior, geom
	FROM public.jeju_node;') AS outdoor (building_id INTEGER, gid INTEGER, name TEXT, type INTEGER, floor DOUBLE PRECISION, exterior BOOLEAN, geom GEOMETRY);
    
-- building_link
CREATE TABLE public.building_link
(
    building_id integer,
    link_id integer,
    link_type integer,
    floor double precision,
    source integer,
    target integer,
    dist double precision,
    geom geometry
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.building_link
    OWNER to postgres;

INSERT INTO public.building_link(
	building_id, link_id, link_type, floor, source, target, dist, geom)
    SELECT * FROM dblink('dblink-indoor', 'SELECT 1 AS building_id, gid, 0 as type, floor, fpoint_id, spoint_id, length, geom
	FROM public.jeju_link;') AS outdoor (building_id INTEGER, gid INTEGER, type INTEGER, floor DOUBLE PRECISION, source INTEGER, target INTEGER, length DOUBLE PRECISION, geom GEOMETRY);
    
    
-------------------------------------------------------------
-- create index
-------------------------------------------------------------
-- primary key
ALTER TABLE public.route
    ADD CONSTRAINT route_pkey PRIMARY KEY (route_id)
;
ALTER TABLE public.p_st
    ADD CONSTRAINT p_st_pkey PRIMARY KEY (pseudo_id)
;
ALTER TABLE public.route_link
    ADD CONSTRAINT route_link_pkey PRIMARY KEY (link_id)
;

ALTER TABLE public.its_node
    ADD CONSTRAINT its_node_pkey PRIMARY KEY (gid)
;
ALTER TABLE public.its_link
    ADD CONSTRAINT its_link_pkey PRIMARY KEY (gid)
;

ALTER TABLE public.building
    ADD CONSTRAINT builidng_pkey PRIMARY KEY (building_id)
;

-- index
CREATE INDEX route_pst_pkey
    ON public.route USING btree
    (p_st_ary ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX route_st_idx
    ON public.route_st USING btree
    (route_id ASC NULLS LAST, station_id ASC NULLS LAST)
    TABLESPACE pg_default;
CREATE INDEX route_st_seq
    ON public.route_st USING btree
    (route_id ASC NULLS LAST, seq ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX route_station_time_idx
    ON public.route_station_time USING btree
    (pseudo_id ASC NULLS LAST, dep_time ASC NULLS LAST)
    TABLESPACE pg_default;
CREATE INDEX total_idx
    ON public.route_station_time USING btree
    (route_id ASC NULLS LAST, route_seq ASC NULLS LAST, dep_time ASC NULLS LAST, pseudo_id ASC NULLS LAST, station_seq ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX route_time_idx
    ON public.route_time USING btree
    (route_id ASC NULLS LAST, seq ASC NULLS LAST)
    TABLESPACE pg_default;
CREATE INDEX time_series_idx
    ON public.route_time USING btree
    (time_series ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX p_st_idx
    ON public.p_st USING btree
    (station_id ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX station_transfer_idx
    ON public.station_transfer USING btree
    (f_id ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX route_link_idx
    ON public.route_link USING btree
    (route_id ASC NULLS LAST)
    TABLESPACE pg_default;