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

	