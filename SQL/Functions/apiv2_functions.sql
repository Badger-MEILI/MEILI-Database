CREATE OR REPLACE FUNCTION apiv2.ap_get_probable_modes_of_tripleg_json(triplegid integer)
  RETURNS json AS
$BODY$ 
select array_to_json(array_agg((SELECT x FROM (SELECT 0 as accuracy, id, name_ as name, name_sv) x) )) as mode FROM apiv2.travel_mode_table; 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.ap_get_probable_modes_of_tripleg_json(triplegid integer) is 
$bd$
Gets the travel mode schema, together with the accuracy / confidence for each purpose (0 by default in the lack of any extra logic)
$bd$;

CREATE OR REPLACE FUNCTION apiv2.ap_get_purposes()
  RETURNS json AS
$BODY$ 
select array_to_json(array_agg((SELECT x FROM (SELECT 0 as accuracy, id, name_ as name, name_sv) x) )) as mode FROM apiv2.purpose_table
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.ap_get_purposes()  is 
$bd$
Gets the purpose schema, together with the accuracy / confidence for each purpose (0 by default in the lack of any extra logic)
$bd$;

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
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.ap_get_transit_pois_of_tripleg_within_buffer(bigint, bigint, bigint, double precision) IS 'Extracts the transportation POIs at next to the location at the end of a time period';


CREATE OR REPLACE FUNCTION apiv2.pagination_get_next_process(IN user_id integer)
  RETURNS TABLE(trip_id integer, current_trip_start_date bigint, current_trip_end_date bigint, previous_trip_end_date bigint, previous_trip_purpose integer, previous_trip_poi_name text, next_trip_start_date bigint, purposes json) AS
$BODY$
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
 $BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;

COMMENT ON FUNCTION apiv2.pagination_get_next_process(integer) IS 'Gets the earliest unannotated trip of a user by user id';

CREATE OR REPLACE FUNCTION apiv2.pagination_get_tripleg_with_id(IN tripleg_id integer)
  RETURNS TABLE(triplegid integer, start_time bigint, stop_time bigint, type_of_tripleg smallint, points json, mode json, places json) AS
$BODY$
select tripleg_id as triplegid, from_time as start_time, to_time as stop_time, type_of_tripleg, 
json_agg(row_to_json((select r from (select l.id, l.lat_ as lat, l.lon_ as lon, l.time_ as time) r))) as points,
(select * from apiv2.ap_get_probable_modes_of_tripleg_json(tripleg_id)) as modes,
(select * from apiv2.ap_get_transit_pois_of_tripleg_within_buffer(tl.user_id, tl.from_time, tl.to_time, 200)) as places
from (select * from apiv2.unprocessed_triplegs WHERE tripleg_id = $1) tl,
raw_data.location_table l
where l.time_ between tl.from_time and tl.to_time and l.accuracy_<=50
and l.user_id = tl.user_id
group by tripleg_id, type_of_tripleg, tl.user_id, from_time, to_time
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION apiv2.pagination_get_tripleg_with_id(integer)
  OWNER TO postgres;

COMMENT ON FUNCTION apiv2.pagination_get_tripleg_with_id(integer) IS 'Gets an unannotated tripleg by its id';

CREATE OR REPLACE FUNCTION apiv2.pagination_get_triplegs_of_trip(trip_id integer)
  RETURNS json AS
$BODY$
select json_agg(l1.*) from
(select tripleg_id from apiv2.unprocessed_triplegs where trip_id = $1) l2
join lateral (select * from apiv2.pagination_get_tripleg_with_id(l2.tripleg_id)) l1
on true
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.pagination_get_triplegs_of_trip(integer) IS 'Retrieves the unannotated triplegs of a trip by the trip_id';



CREATE OR REPLACE FUNCTION apiv2.confirm_annotation_of_trip_get_next(IN trip_id bigint)
  RETURNS TABLE(trip_id integer, current_trip_start_date bigint, current_trip_end_date bigint, previous_trip_end_date bigint, previous_trip_purpose integer, previous_trip_poi_name text, next_trip_start_date bigint, purposes json) AS
$BODY$
	with inserted_trip as (
	insert into apiv2.trips_gt (trip_inf_id, user_id, 
	from_time, to_time, type_of_trip, purpose_id, destination_poi_id)
	(select trip_id, user_id, from_time, to_time, type_of_trip, purpose_id, destination_poi_id 
	from apiv2.trips_inf where trip_id = $1)
	returning user_id
	),
	inserted_triplegs as (
	insert into apiv2.triplegs_gt (tripleg_inf_id, trip_id, user_id, from_time, to_time, type_of_tripleg, transportation_type, transition_poi_id)
	(select tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg, transportation_type, transition_poi_id
	from apiv2.triplegs_inf where trip_id = $1)
	returning user_id
	),
	distinct_user_id as (select distinct user_id from (select * from inserted_trip union all select * from inserted_triplegs) union_of_tables)
	select pagination_get_next_process from distinct_user_id 
	left join lateral apiv2.pagination_get_next_process(user_id::int) ON TRUE; 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.confirm_annotation_of_trip_get_next(IN trip_id bigint) IS 
$bd$
CONFIRMS THAT THE TRIP WAS ANNOTATED, IF THIS IS NOT PREVENTED BY TRIGGERS.
$bd$;


CREATE OR REPLACE FUNCTION apiv2.delete_trip(IN trip_id integer)
  RETURNS TABLE(trip_id integer, current_trip_start_date bigint, current_trip_end_date bigint, previous_trip_end_date bigint, previous_trip_purpose integer, previous_trip_poi_name text, next_trip_start_date bigint, purposes json) AS
$BODY$
with  
	deleted_trip as (
	DELETE FROM apiv2.trips_inf where 
	trip_id = $1 returning user_id 
	)

	select pagination_get_next_process from deleted_trip
	left join lateral apiv2.pagination_get_next_process(user_id::int) ON TRUE; 

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.delete_trip(IN trip_id integer) IS 
$bd$
DELETES A TRIP AND RETURNS THE NEXT TRIP THAT THE USER HAS TO ANNOTATE
$bd$;


CREATE OR REPLACE FUNCTION apiv2.delete_tripleg(tripleg_id integer)
  RETURNS json AS
$BODY$
with  
	deleted_trip as (
	DELETE FROM apiv2.triplegs_inf where tripleg_id = $1 returning trip_id 
	)

	select pagination_get_triplegs_of_trip from deleted_trip
	left join lateral apiv2.pagination_get_triplegs_of_trip(trip_id) ON TRUE; 

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.delete_tripleg(tripleg_id integer) IS 
$bd$
DELETES A TRIPLEG AND RETURNS THE MODIFIED TRIPLEGS OF THE DELETED TRIPLEGs PARRENT TRIP 
$bd$; 

CREATE OR REPLACE FUNCTION apiv2.insert_destination_poi(
    name text,
    latitude double precision,
    longitude double precision,
    declaring_user_id integer)
  RETURNS integer AS
$BODY$
	INSERT INTO apiv2.pois(name_, lat_, lon_, user_id, is_personal, geom)
	VALUES ($1, $2, $3, $4, true, st_transform(st_setsrid(st_makepoint($3, $2), 4326), 3006))
	RETURNING gid
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.insert_destination_poi(name text, latitude double precision, longitude double precision, declaring_user_id integer) IS
$bd$
INSERTS A NEW DESTINATION POI AS DEFINED BY A USER AND RETURNS THE ID OF THE INSERTED POINT 
$bd$; 

CREATE OR REPLACE FUNCTION apiv2.insert_transition_poi(name text, latitude double precision, longitude double precision, declaring_user_id integer, transportation_lines text, transportation_types text)
  RETURNS integer AS
$BODY$
	INSERT INTO apiv2.poi_transportation
	(name_, lat_, lon_, declaring_user_id, declared_by_user, geom, transportation_lines, transportation_types)
	VALUES ($1, $2, $3, $4, true, st_transform(st_setsrid(st_makepoint($3, $2), 4326), 3006), $5, $6)
	RETURNING gid
$BODY$
LANGUAGE sql VOLATILE 
COST 100;

COMMENT ON FUNCTION apiv2.insert_transition_poi(name text, latitude double precision, longitude double precision, declaring_user_id integer, transportation_lines text, transportation_types text) IS 
$bd$
INSERTS A NEW TRANSITION POI AS DEFINED BY THE USER AND RETURNS THE ID OF THE INSERTED POI
$bd$;


CREATE OR REPLACE FUNCTION apiv2.insert_stationary_trip_for_user(IN from_time bigint, IN to_time bigint, IN user_id integer)
  RETURNS TABLE(trip_id integer, current_trip_start_date bigint, current_trip_end_date bigint, previous_trip_end_date bigint, previous_trip_purpose integer, previous_trip_poi_name text, next_trip_start_date bigint, purposes json) AS
$BODY$
with 
	affected_trip as (select * from apiv2.trips_inf where type_of_trip = 1 and 
				user_id = $3
				and $1 > from_time and $1 < to_time
				and $2 > from_time and $2 < to_time
				), 
	affected_non_movement_trip_period as (select * from apiv2.trips_inf where type_of_trip = 0 and from_time >= (select to_time from affected_trip) order by from_time, to_time limit 1),
	updated_affected_trip as (UPDATE apiv2.trips_inf set to_time = $1 where trip_id = (select trip_id from affected_trip) returning user_id),
	inserted_stationary_period as (INSERT INTO apiv2.trips_inf(user_id, from_time, to_time, type_of_trip, parent_trip_id)
					select user_id, $1, $2, 0, trip_id from affected_trip returning *),
	inserted_movement_period as (INSERT INTO apiv2.trips_inf(user_id, from_time, to_time, type_of_trip, parent_trip_id)
					select user_id, $2, to_time , 1, trip_id from affected_trip returning *), 
	inserted_stationary_tripleg as (INSERT INTO apiv2.triplegs_inf(user_id, from_time, to_time, type_of_tripleg, trip_id, parent_tripleg_id)
					select user_id, from_time, to_time, 1, trip_id, trip_id * (-1)from inserted_stationary_period returning user_id), 
	inserted_movement_tripleg as (INSERT INTO apiv2.triplegs_inf(user_id, from_time, to_time, type_of_tripleg, trip_id, parent_tripleg_id)
					select user_id, from_time, to_time, 1, trip_id, trip_id*(-1) from inserted_movement_period returning user_id),  
		
	returning_user_id as (SELECT distinct user_id FROM ( 
				select * from inserted_stationary_tripleg 
				union all select * from inserted_movement_tripleg
				union all select * from updated_affected_trip
				) foo)

	select t.* from returning_user_id 
	left join lateral apiv2.pagination_get_next_process(user_id::int) t ON TRUE; 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.insert_stationary_trip_for_user(IN from_time bigint, IN to_time bigint, IN user_id integer) IS 
$bd$
INSERTS A NON MOVEMENT PERIOD THAT WAS MISSED BY THE SEGMENTATION ALGORITHM BETWEEN TWO TRIPS - TAKES A TRIP, SPLITS IT IN TWO AND INSERTS A NON-MOVEMENT PERIOD IN BETWEEN
$bd$;

CREATE OR REPLACE FUNCTION apiv2.insert_stationary_tripleg_period_in_trip(from_time bigint, to_time bigint, from_travel_mode integer, to_travel_mode integer, trip_id integer)
  RETURNS json AS
$BODY$
with 
	affected_tripleg as (select * from apiv2.triplegs_inf where type_of_tripleg = 1 and 
				trip_id = $5
				and $1 > from_time and $1 < to_time
				and $2 > from_time and $2 < to_time
				),
	inserted_stationary_period as (INSERT INTO apiv2.triplegs_inf(user_id, from_time, to_time, type_of_tripleg, trip_id, parent_tripleg_id)
					select user_id, $1, $2, 0, trip_id, tripleg_id from affected_tripleg returning trip_id), 
	inserted_movement_period as (INSERT INTO apiv2.triplegs_inf(user_id, from_time, to_time, type_of_tripleg, transportation_type, trip_id, parent_tripleg_id)
					select user_id, $2, to_time , 1, $4, trip_id, tripleg_id from affected_tripleg returning trip_id),
	updated_affected_tripleg as (UPDATE apiv2.triplegs_inf set to_time = $1, transportation_type = $3 where tripleg_id = (select tripleg_id from affected_tripleg) returning trip_id),
	returning_trip_id as (SELECT distinct trip_id FROM (select * from inserted_stationary_period union all select * from inserted_movement_period union all select * from updated_affected_tripleg) foo)

	select pagination_get_triplegs_of_trip from returning_trip_id 
	left join lateral apiv2.pagination_get_triplegs_of_trip(trip_id) ON TRUE; 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.insert_stationary_tripleg_period_in_trip(from_time bigint, to_time bigint, from_travel_mode integer, to_travel_mode integer, trip_id integer) IS
$bd$
INSERTS A NEW TRANSITION THAT WAS MISSED BY THE SEGMENTATION ALGORITHM IN BETWEEN TWO TRIPLEGS - TAKES A TRIPLEG, SPLITS IT IN TWO AND INSERTS A NON-MOVEMENT TRIPLEG IN BETWEEN
$bd$;

CREATE OR REPLACE FUNCTION apiv2.update_trip_destination_poi_id(destination_poi_id bigint, trip_id integer)
  RETURNS boolean AS
$BODY$
	UPDATE apiv2.trips_inf SET destination_poi_id = $1 
	WHERE trip_id = $2 
	RETURNING TRUE; 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.update_trip_destination_poi_id(destination_poi_id bigint, trip_id integer) IS 
$bd$
UPDATES THE DESTINATION POI ID OF A TRIP 
$bd$;

CREATE OR REPLACE FUNCTION apiv2.update_trip_purpose(purpose_id integer, trip_id integer)
  RETURNS boolean AS
$BODY$
	UPDATE apiv2.trips_inf SET purpose_id = $1 
	WHERE trip_id = $2 
	RETURNING TRUE; 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.update_trip_purpose(purpose_id integer, trip_id integer) IS 
$bd$
UPDATES THE PURPOSE ID OF A TRIP
$bd$; 


CREATE OR REPLACE FUNCTION apiv2.update_trip_end_time(to_time bigint, trip_id integer)
  RETURNS json AS
$BODY$
with 
	-- get the details of the trip that should be updated 
	trip_details as (
	select trip_id, from_time, to_time from apiv2.unprocessed_trips where trip_id = $2
	),
	-- get the trips that will be affected by the update (both fully within and partially overlapping)
	affected_trips_by_update as (
	select trips.*, 
			-- trips that are fully within the proposed updated timestamps
			case when trips.to_time between tl.to_time and $1 then 'DELETE'
			-- trips that are partially overlapping the proposed updated timestamps
			else case when trips.from_time between tl.to_time and $1 then 'UPDATE' 
			-- error that should never occur 
			else 'ERROR' end end as action_needed 
		from apiv2.trips_inf trips, trip_details tl  
		where trips.trip_id <> tl.trip_id 
		-- temporal join constraint 
		and (trips.from_time between tl.to_time and $1
			or trips.to_time between tl.to_time and $1)),
	-- updated trips 
	updated_neighboring_trips as (update apiv2.trips_inf set from_time = $1 where trip_id = any (select trip_id from affected_trips_by_update where action_needed = 'UPDATE' and type_of_trip = 1) returning $2 as trip_id),
	-- the initially updated trip 
	updated_current_trip as (update apiv2.trips_inf set to_time = $1 where trip_id = $2 returning trip_id), 
	-- the deleted trips
	deleted_trips as (delete from apiv2.trips_inf tl2 where tl2.trip_id = any (select trip_id from affected_trips_by_update where action_needed = 'DELETE' and type_of_trip = 1) returning $2 as trip_id),
	returning_trip_id as (SELECT distinct trip_id FROM (select * from deleted_trips union all select * from updated_neighboring_trips union all select *from updated_current_trip)  foo) 

	select pagination_get_triplegs_of_trip from returning_trip_id 
	left join lateral apiv2.pagination_get_triplegs_of_trip(trip_id) ON TRUE; 

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.update_trip_end_time(to_time bigint, trip_id integer) IS 
$bd$
UPDATES THE END TIME OF A TRIP AND PROPAGATES ANY TEMPORAL MODIFICATIONS TO ITS NEXT NEIGHBORING TRIPS
$bd$;

CREATE OR REPLACE FUNCTION apiv2.update_trip_start_time(
    from_time_ bigint,
    trip_id_ integer)
  RETURNS json AS
$BODY$
DECLARE 
response json;
BEGIN 
	update apiv2.trips_inf set 
	from_time = $1 where trip_id = $2;
	response := apiv2.pagination_get_triplegs_of_trip($2);
	return response;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100; 

COMMENT ON FUNCTION apiv2.update_trip_start_time(from_time bigint, trip_id integer) IS 
$bd$
UPDATES THE START TIME OF A TRIP AND PROPAGATES ANY TEMPORAL MODIFICATION TO ITS PRECEEDING NEIGHBORING NON MOVEMENT TRIP
$bd$; 

CREATE OR REPLACE FUNCTION apiv2.update_tripleg_end_time(to_time bigint, tripleg_id integer)
  RETURNS json AS
$BODY$
with 
	-- get the details of the tripleg that should be updated 
	tripleg_details as (
	select tripleg_id, from_time, to_time, trip_id from apiv2.unprocessed_triplegs where tripleg_id = $2
	),
	-- get the triplegs that will be affected by the update (both fully within and partially overlapping)
	affected_triplegs_by_update as (
	select tlgs.*, 
			-- triplegs that are fully within the proposed updated timestamps
			case when tlgs.to_time between tl.to_time and $1 then 'DELETE'
			-- triplegs that are partially overlapping the proposed updated timestamps
			else case when tlgs.from_time between tl.to_time and $1 then 'UPDATE' 
			-- error that should never occur 
			else 'ERROR' end end as action_needed 
		from apiv2.unprocessed_triplegs tlgs, tripleg_details tl 
		-- have same trip id but be different from the updated tripleg
		where tlgs.trip_id = tl.trip_id and tlgs.tripleg_id <> tl.tripleg_id
		-- only consider movement periods, the stationary periods are dealt with exclusively by triggers 
		and tlgs.type_of_tripleg = 1 
		-- temporal join constraint 
		and (tlgs.from_time between tl.to_time and $1
			or tlgs.to_time between tl.to_time and $1)),
	-- updated triplegs 
	updated_neighboring_triplegs as (update apiv2.triplegs_inf set from_time = $1 where tripleg_id = any (select tripleg_id from affected_triplegs_by_update where action_needed = 'UPDATE') returning trip_id),
	-- the initially updated tripleg 
	updated_current_tripleg as (update apiv2.triplegs_inf set to_time = $1 where tripleg_id = $2 returning trip_id), 
	-- the deleted triplegs
	deleted_triplegs as (delete from apiv2.triplegs_inf tl2 where tl2.tripleg_id = any (select tripleg_id from affected_triplegs_by_update where action_needed = 'DELETE') returning trip_id),
	returning_trip_id as (SELECT distinct trip_id FROM (select * from updated_neighboring_triplegs union all select * from updated_current_tripleg union all select * from deleted_triplegs ) foo) 

	select pagination_get_triplegs_of_trip from returning_trip_id 
	left join lateral apiv2.pagination_get_triplegs_of_trip(trip_id) ON TRUE; 

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.update_tripleg_end_time(to_time bigint, tripleg_id integer) IS 
$bd$
MODIFIES THE END TIME OF A TRIPLEG AND PROPAGATES ANY TEMPORAL MODIFICATIONS TO ALL ITS NEIGHBORING NEXT TRIPLEGS
$bd$; 

CREATE OR REPLACE FUNCTION apiv2.update_tripleg_start_time(from_time bigint, tripleg_id integer)
  RETURNS json AS
$BODY$
with 
	-- get the details of the tripleg that should be updated 
	tripleg_details as (
	select tripleg_id, from_time, to_time, trip_id from apiv2.unprocessed_triplegs where tripleg_id = $2
	),
	-- get the triplegs that will be affected by the update (both fully within and partially overlapping)
	affected_triplegs_by_update as (
	select tlgs.*, 
			-- triplegs that are fully within the proposed updated timestamps
			case when tlgs.from_time between $1 and tl.from_time then 'DELETE'
			-- triplegs that are partially overlapping the proposed updated timestamps
			else case when tlgs.to_time between $1 and tl.from_time then 'UPDATE' 
			-- error that should never occur 
			else 'ERROR' end end as action_needed 
		from apiv2.unprocessed_triplegs tlgs, tripleg_details tl 
		-- have same trip id but be different from the updated tripleg
		where tlgs.trip_id = tl.trip_id and tlgs.tripleg_id <> tl.tripleg_id
		-- only consider movement periods, the stationary periods are dealt with exclusively by triggers 
		and tlgs.type_of_tripleg = 1 
		-- temporal join constraint 
		and (tlgs.from_time between $1 and tl.from_time
			or tlgs.to_time between $1 and tl.from_time)),
	-- updated triplegs 
	updated_neighboring_triplegs as (update apiv2.triplegs_inf set to_time = $1 where tripleg_id = any (select tripleg_id from affected_triplegs_by_update where action_needed = 'UPDATE') returning trip_id),
	-- the initially updated tripleg 
	updated_current_tripleg as (update apiv2.triplegs_inf set from_time = $1 where tripleg_id = $2 returning trip_id), 
	-- the deleted triplegs
	deleted_triplegs as (delete from apiv2.triplegs_inf tl2 where tl2.tripleg_id = any (select tripleg_id from affected_triplegs_by_update where action_needed = 'DELETE') returning trip_id),
	returning_trip_id as (SELECT distinct trip_id FROM (select * from updated_neighboring_triplegs union all select * from updated_current_tripleg union all select * from deleted_triplegs ) foo) 

	select pagination_get_triplegs_of_trip from returning_trip_id 
	left join lateral apiv2.pagination_get_triplegs_of_trip(trip_id) ON TRUE; 

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.update_tripleg_start_time(from_time bigint, tripleg_id integer) IS 
$bd$
MODIFIES THE START TIME OF A TRIPLEG AND PROPAGATES ANY TEMPORAL MODIFICATIONS TO ALL ITS NEIGHBORING PREVIOUS TRIPLEGS
$bd$;


CREATE OR REPLACE FUNCTION apiv2.update_tripleg_transition_poi_id(transition_poi_id integer, tripleg_id integer)
  RETURNS boolean AS
$BODY$
	UPDATE apiv2.triplegs_inf set transition_poi_id = $1 where tripleg_id = $2
	RETURNING true;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.update_tripleg_transition_poi_id(transition_poi_id integer, tripleg_id integer) IS 
$bd$
UPDATES THE TRANSITION POI ID OF A GIVEN TRIPLEG 
$bd$; 

CREATE OR REPLACE FUNCTION apiv2.update_tripleg_travel_mode(travel_mode integer, tripleg_id integer)
  RETURNS boolean AS
$BODY$
	UPDATE apiv2.triplegs_inf set transportation_type = $1 where tripleg_id = $2
	RETURNING true;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.update_tripleg_travel_mode(travel_mode integer, tripleg_id integer) IS 
$bd$
UPDATES THE TRAVEL MODE OF A GIVEN TRIPLEG
$bd$; 

CREATE OR REPLACE FUNCTION apiv2.user_get_badge_trips_info(user_id integer)
  RETURNS bigint AS
$BODY$
		select count(*) from apiv2.unprocessed_trips 
		where user_id = $1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.user_get_badge_trips_info(user_id integer) IS 
$bd$
GETS THE NUMBER OF TRIPS THAT A USER CAN ANNOTATE 
$bd$; 
