DROP TYPE trips;
DROP TYPE trip;

CREATE TYPE trip AS(
    route_desc_id NUMERIC,
    dep_st INTEGER,
    arr_st INTEGER,
    dep_time INTEGER,
    arr_time INTEGER
);

CREATE OR REPLACE FUNCTION create_trip(
    IN route_desc_id NUMERIC,
    IN dep_st INTEGER,
    IN arr_st INTEGER,
    IN dep_time INTEGER,
    IN arr_time INTEGER
) RETURNS trip AS
$$
    SELECT route_desc_id, dep_st, arr_st, dep_time, arr_time
$$ LANGUAGE SQL;

CREATE TYPE trips AS(
    list trip[]
);
