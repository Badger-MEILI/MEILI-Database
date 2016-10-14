select * from plan(9);

	-- 1. updating the start time of a trip will result in updating the end time of the previous stationary trip period
	-- Relation 
	/*select lives_ok($bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the start time of a trip updates the start time of its first tripleg');*/
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint$bd$,
	'trip start time update induces previous non movement trip end time update');		
	
	-- 2. updating the end time of a trip will result in updating the end time of the next stationary trip period
	-- Relation to 
	/* select lives_ok($bd$UPDATE apiv2.trips_inf set to_time = (select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the end time of a trip updates the end time of its last tripleg'); */
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -5', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint$bd$,
	'trip end time update induces next non movement trip start time update');		
	
	-- 3. cannot update the start time of a trip more than the end time of a previous active trip  

	SELECT throws_ok(
	$bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 10:12:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$,
	null,
	null,
	'Cannot overlap previous trip movement periods'
	); 
		
	-- 4. updating the end time of a trip will result in deleting all the trips that fall within the period [old.end_time and new.end_time] and not throw errors
	SELECT lives_ok(
	$bd$SELECT * FROM apiv2.update_trip_end_time(1000 * extract (epoch from '2016-09-26 23:12:00'::timestamp without time zone)::bigint,
	-6)$bd$, 
	'Cannot overlap previous trip movement periods'
	); 
	
	-- 5. updating the end time of a trip will delete next movement trip period if overlapping 
	SELECT is_empty( 
	'SELECT trip_id from apiv2.trips_inf where trip_id = -4',  
	'next trip should not exist');		
	
	-- 6. updating the end time of a trip that overlaps a neighboring active trip will update the start_time of the neighboring trip to the suggested end_time, which will also trigger the update of the tripleg's time
	SELECT lives_ok(
	$bd$SELECT * FROM apiv2.update_trip_end_time(
	1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint,
	-8)$bd$, 
	'Cannot overlap previous trip movement periods'
	); 

	-- 7. next non movement trip period should exist and have the start time equal to the updated end time of trip 6
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'next non movement trip exists and has correct start time');		

	-- 8. next non movement trip period should exist and have the end time equal to the updated end time of trip 6
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'next non movement trip exists and has correct start time');		

	-- 9. next movement trip period should exist and have the start time equal to the updated end time of trip 6
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -6', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'next non movement trip exists and has correct start time');		


SELECT * FROM FINISH();
