select * from plan(8);

	-- 1. updating the start time of a trip will result in updating the start time of the only tripleg of that trip 	
	select lives_ok($bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 09:24:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -10;$bd$, 
	'Update of the start time of a trip updates the start time of its only tripleg'); 

	-- 2. updating the start time of a trip will result in updating the start time of the only tripleg of that trip 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -18', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 09:24:00'::timestamp without time zone)::bigint$bd$,
	'trip start time update induces tripleg start time update');		
	
	-- 3. updating the start time of a trip will result in updating the start time of the first tripleg of that trip 
	select lives_ok($bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the start time of a trip updates the start time of its first tripleg'); 

	-- 4. updating the start time of a trip will result in updating the start time of the first tripleg of that trip 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -14', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint$bd$,
	'trip start time update induces tripleg start time update');		

	-- 5. updating the end time of a trip will result in updating the end time of the only tripleg of that trip 	
	select lives_ok($bd$UPDATE apiv2.trips_inf set to_time = (select 1000 * extract (epoch from '2016-09-26 20:40:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -4;$bd$, 
	'Update of the end time of a trip updates the end time of its only tripleg'); 

	-- 6. updating the end time of a trip will result in updating the end time of the only tripleg of that trip 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -8', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 20:40:00'::timestamp without time zone)::bigint$bd$,
	'trip end time update induces tripleg end time update');		
	
	-- 7. updating the end time of a trip will result in updating the end time of the last tripleg of that trip 
	select lives_ok($bd$UPDATE apiv2.trips_inf set to_time = (select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the end time of a trip updates the end time of its last tripleg'); 

	-- 8. updating the end time of a trip will result in updating the end time of the last tripleg of that trip 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -10', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint$bd$,
	'trip end time update induces tripleg end time update');		


SELECT * FROM FINISH();
