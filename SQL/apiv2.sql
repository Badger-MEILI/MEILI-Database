-- schema for the new version of the api 
create schema v2api;

/*
Unannotated trips and triplegs for pagination 
*/

-- view that will serve the unannotated trips to the user on the pagination - selection by user_id
create view v2api.unprocessed_trips as 
	select * from trips_inf as ti where 
	from_time>= (
	select max(tg.to_time) from trips_gt tg where 
	tg.user_id = ti.user_id
	and tg.type_of_trip = 1)  
	and ti.type_of_trip = 1;

-- view that will serve the unprocessed triplegs per trip 
create view v2api.unprocessed_triplegs as 
	select * from triplegs_inf where trip_id = 
	any (select trip_id from v2api.unprocessed_trips);

-- paginates to the first unannotated trip that the user has to interact with

create function v2api.pagination_get_next_process(user_id integer)
returns table (trip_id integer, current_trip_start_date bigint, 
current_trip_end_date bigint, 
previous_trip_end_date bigint, previous_trip_purpose integer, previous_trip_poi_name text, 
next_trip_start_date bigint,
purposes json) as 
$b$
with first_unprocessed_trip as (
	select * from v2api.unprocessed_trips 
	where user_id = $1
	order by from_time, to_time 
	limit 1), 
	last_processed_trip as (
	select * from v2api.processed_trips 
	where user_id = $1 
	order by from_time desc, to_time desc 
	limit 1),
	next_trip_to_process as (
	select * from unprocessed_trips 
	where user_id = $1 
	and trip_id> (select trip_id from first_unprocessed_trip)
	limit 1
	)

select first.trip_id, 
	first.from_time as current_trip_start_date, first.to_time as current_trip_end_date, 
	last.to_time as previous_trip_end_date, last.purpose_id as last_trip_purpose, 
	(select name_ from poi_personal where gid = last.destination_poi_id
	union select coalesce (name_,type_) from poi_public where osm_id = last.destination_poi_id
	limit 1) as previous_trip_poi,
	next.from_time as next_trip_start_date,
	(select * from ap_get_purposes()) as purposes
	 from first_unprocessed_trip first, last_processed_trip last,
	 next_trip_to_process next 
 $b$ 
 LANGUAGE SQL;

/*
Annotated trips and triplegs annotation 
*/
-- view that will serve the annotated trips to the user on request
create view v2api.processed_trips as 
	select * from trips_gt where type_of_trip = 1;

-- view that will serve the annotated triplegs per trip
create view v2api.processed_triplegs as 
	select * from triplegs_inf where trip_id = 
	any (select trip_id from v2api.processed_trips);	
