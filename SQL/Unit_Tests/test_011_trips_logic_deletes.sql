select * from plan(11);

	-- 1. deleting a trip with multiple triplegs is allowed 
	SELECT lives_ok(
	$bd$DELETE from apiv2.trips_inf where trip_id = -6 $bd$, 
	'The trip should be deleted'
	); 

	-- 2. deleted trip sould not exist
	SELECT is_empty( 
	'SELECT trip_id from apiv2.trips_inf where trip_id = -6',  
	'delete trip should not exist');		

	-- 3. deleted trip next non movement period sould not exist
	SELECT is_empty( 
	'SELECT trip_id from apiv2.trips_inf where trip_id = -5',  
	'delete trip next non movement period should not exist');		

	-- 4. previous neighboring trip of deleted trip should have the same start time as before 
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -8', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone)::bigint$bd$,
	'previous neighboring trip of deleted trip should have the same start time as before');		

	-- 5. previous neighboring trip of deleted trip should have the same end time as before 
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -8', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'previous neighboring trip of deleted trip should have the same end time as before');			

	-- 6. previous non movement neighboring trip of deleted trip should have the same start time as before 
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'previous non movement neighboring trip of deleted trip should have the same start time as before ');			

	-- 7. previous non movement neighboring trip of deleted trip should have the end time equal to that of the deleted trip
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 23:12:00'::timestamp without time zone)::bigint$bd$,
	'previous non movement neighboring trip of deleted trip should have the end time equal to that of the deleted trip');			
	
	-- 8. deleting a trip should delete all the triplegs belonging to that trip 
	SELECT is_empty( 
	'SELECT tripleg_id from apiv2.triplegs_inf where trip_id = -6',  
	'deleting a trip should delete all the triplegs belonging to that trip ');		

	-- 9. deleting a trip will merge its previous and next passive triplegs into one - from_time
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -16', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone)::bigint$bd$,
	'tripleg belonging to the previous neighboring trip of deleted trip should have the same start time as before');		

	-- 10. deleting a trip will merge its previous and next passive triplegs into one - to_time
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -16', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'tripleg belonging to the previous neighboring trip of deleted trip should have the same end time with as before');		

	-- 11. deleting a trip will merge its previous and next passive triplegs into one - to_time
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -15', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 23:12:00'::timestamp without time zone)::bigint$bd$,
	'tripleg time consistency after deletion');		


SELECT * FROM FINISH();
