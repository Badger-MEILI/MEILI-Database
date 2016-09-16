CREATE OR REPLACE FUNCTION apiv2.user_get_badge_trips_info(user_id integer)
  RETURNS bigint AS
$BODY$
		select count(*) from apiv2.unprocessed_trips 
		where user_id = $1;
$BODY$
  LANGUAGE sql ;
COMMENT ON FUNCTION apiv2.user_get_badge_trips_info(user_id integer) is 
'Returns the number of trips that a user can annotate';
  
CREATE OR REPLACE FUNCTION apiv2.ap_get_purposes()
  RETURNS json AS
$BODY$ 
select array_to_json(array_agg((SELECT x FROM (SELECT 0 as accuracy, id, name_ as name, name_sv) x) )) as mode FROM apiv2.purpose_table
$BODY$
  LANGUAGE sql VOLATILE;
COMMENT ON FUNCTION apiv2.ap_get_purposes() is 
'Returns an array of the studied purposes';

-- paginates to the first unannotated trip that the user has to interact with

CREATE OR REPLACE FUNCTION apiv2.pagination_get_next_process(user_id integer)
returns table (trip_id integer, current_trip_start_date bigint,
current_trip_end_date bigint,
previous_trip_end_date bigint, previous_trip_purpose integer, previous_trip_poi_name text,
next_trip_start_date bigint,
purposes json) as
$b$
with first_unprocessed_trip as (
        select * from apiv2.unprocessed_trips
        where user_id = $1
        order by from_time, to_time
        limit 1),
        last_processed_trip as (
        select * from apiv2.processed_trips
        where user_id = $1
        order by from_time desc, to_time desc
        limit 1),
        exists_previous as (select exists(select * from last_processed_trip)),
        next_trip_to_process as (
        select * from apiv2.unprocessed_trips
        where user_id = $1
        and trip_id> (select trip_id from first_unprocessed_trip)
        limit 1
        ),
        exists_next as (select exists(select * from next_trip_to_process))

select first.trip_id,
        first.from_time as current_trip_start_date, first.to_time as current_trip_end_date,
        case when (select * from exists_previous) then 
		(select to_time from last_processed_trip ) else 0 end as previous_trip_end_date, 
        case when (select * from exists_previous) then 
		(select purpose_id from last_processed_trip) else null end as last_trip_purpose,
        case when (select * from exists_previous) then 
		(select name_ from apiv2.pois where gid = (select destination_poi_id from last_processed_trip)) else '' end as previous_trip_poi,
        case when (select * from exists_next) then (select from_time from next_trip_to_process) else null end as next_trip_start_date,
        (select * from apiv2.ap_get_purposes()) as purposes
         from first_unprocessed_trip first 
 $b$
 LANGUAGE SQL;
COMMENT ON FUNCTION apiv2.pagination_get_next_process(user_id integer) is 
'Gets the earliest unannotated trip of a user';

CREATE OR REPLACE FUNCTION apiv2.ap_get_probable_modes_of_tripleg_json(triplegid integer)
RETURNS json AS
$BODY$ 
select array_to_json(array_agg((SELECT x FROM (SELECT 0 as accuracy, id, name_ as name, name_sv) x) )) as mode FROM apiv2.travel_mode_table; 
$BODY$
  LANGUAGE sql VOLATILE;
COMMENT ON FUNCTION apiv2.ap_get_purposes() is 
'Returns an array of the studied purposes';


CREATE OR REPLACE FUNCTION apiv2.ap_get_transit_pois_of_tripleg_within_buffer(
    user_id bigint,
    from_time bigint,
    to_time bigint,
    buffer_in_meters double precision)
  RETURNS json AS
$BODY$
with 
point as (select lat_, lon_ from raw_data.location_table where user_id = $1 and time_ between $2 and $3 
order by time_ desc limit 1), 
point_geometry as (select st_transform(st_setsrid(st_makepoint(lon_, lat_),4326),3006) as orig_pt_geom from point),
personal_transition_within_buffer as (SELECT osm_id as osm_id, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, 1 as added_by_user from apiv2.poi_transportation as p1, point_geometry as p2 where st_dwithin(p2.orig_pt_geom,p1.geom, $4) and declared_by_user = true),
public_transition_within_buffer as (SELECT osm_id as osm_id, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, -1 as added_by_user from apiv2.poi_transportation as p1, point_geometry as p2 where st_dwithin(p2.orig_pt_geom,p1.geom, $4) and declared_by_user = false)
select array_to_json(array_agg(x)) from (select * from personal_transition_within_buffer union all select * from public_transition_within_buffer) x 
$BODY$
  LANGUAGE sql;
COMMENT ON FUNCTION apiv2.ap_get_transit_pois_of_tripleg_within_buffer(user_id bigint, from_time bigint, to_time bigint, buffer_in_meters double precision) 
IS 'Extracts the transportation at the end of a time period';

CREATE OR REPLACE FUNCTION apiv2.pagination_get_tripleg_with_id(IN tripleg_id integer)
  RETURNS TABLE(triplegid integer, type_of_tripleg smallint, points json, mode json, places json) AS
$BODY$
select tripleg_id as triplegid, type_of_tripleg, 
json_agg(row_to_json((select r from (select l.id, l.lat_ as lat, l.lon_ as lon, l.time_ as time) r))) as points,
(select * from apiv2.ap_get_probable_modes_of_tripleg_json(tripleg_id)) as modes,
(select * from apiv2.ap_get_transit_pois_of_tripleg_within_buffer(tl.user_id, tl.from_time, tl.to_time, 200)) as places
from (select * from apiv2.unprocessed_triplegs WHERE tripleg_id = $1) tl,
raw_data.location_table l
where l.time_ between tl.from_time and tl.to_time and l.accuracy_<=50
and l.user_id = tl.user_id
group by tripleg_id, type_of_tripleg, tl.user_id, from_time, to_time
$BODY$
  LANGUAGE sql VOLATILE;;
COMMENT ON FUNCTION apiv2.pagination_get_tripleg_with_id(IN tripleg_id integer) is 
'Gets a given unannotated triplegs';


CREATE OR REPLACE FUNCTION apiv2.pagination_get_triplegs_of_trip(trip_id integer)
  RETURNS json AS
$BODY$
select json_agg(l1.*) from
(select tripleg_id from apiv2.unprocessed_triplegs where trip_id = $1) l2
join lateral (select * from apiv2.pagination_get_tripleg_with_id(l2.tripleg_id)) l1
on true
$BODY$
  LANGUAGE sql;
COMMENT ON FUNCTION apiv2.pagination_get_triplegs_of_trip(trip_id integer) is
'Retrieves the unannotated triplegs of a given trip';