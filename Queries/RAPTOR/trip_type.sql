DROP FUNCTION create_trip;
DROP TYPE trips;
DROP TYPE trip;

CREATE TYPE trip AS(
    route_id NUMERIC,
    dep_st INTEGER,
    arr_st INTEGER,
    dep_time INTEGER,
    arr_time INTEGER,
    k DOUBLE PRECISION
);

CREATE OR REPLACE FUNCTION create_trip(
    IN route_id NUMERIC,
    IN dep_st INTEGER,
    IN arr_st INTEGER,
    IN dep_time INTEGER,
    IN arr_time INTEGER,
    IN k DOUBLE PRECISION
) RETURNS trip AS
$$
    SELECT route_id, dep_st, arr_st, dep_time, arr_time, k
$$ LANGUAGE SQL;

CREATE TYPE trips AS(
    list trip[]
);

DROP FUNCTION create_tripQ;
DROP TYPE tripQ;

CREATE TYPE tripQ AS(
    route_id NUMERIC,
    route_seq INTEGER,
    dep_time INTEGER,
    pseudo_id INTEGER,
    station_seq INTEGER
);

CREATE OR REPLACE FUNCTION create_tripQ(
    IN route_id NUMERIC,
    IN route_seq INTEGER,
    IN dep_time INTEGER,
    IN pseudo_id INTEGER,
    IN station_seq INTEGER
) RETURNS tripQ AS
$$
    SELECT route_id, route_seq, dep_time, pseudo_id, station_seq
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION find_tripQ_id(
    IN tbl tripQ[],
    IN route_id NUMERIC
) RETURNS tripQ AS
$$
    SELECT tripQ
    FROM tbl
    WHERE tbl.route_id = route_id
$$ LANGUAGE 'pgpsql';