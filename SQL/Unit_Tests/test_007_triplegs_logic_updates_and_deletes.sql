select * from plan(21);


       -- 1. deleting the first tripleg of a trip shifts the trip's start time 
	delete from apiv2.triplegs_inf where tripleg_id = -20;
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -10', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 09:30:00'::timestamp without time zone)::bigint$bd$,
	'after deleting the first tripleg, the start time of the trip should be the same with the start time of the neighboring movement tripleg of the deleted tripleg');

	-- 2. updating the end time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 17:43:00'::timestamp without time zone)::bigint , -12)$bd$,
	'A mid tripleg update of start time should be allowed'
	);

	-- 3. updating the start time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 17:06:00'::timestamp without time zone)::bigint , -12)$bd$,
	'A mid tripleg update of end time should be allowed'
	);
	
	-- 4. Updating the end time of a tripleg should update the start time of its next non-movement tripleg 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -11', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:43:00'::timestamp without time zone)::bigint$bd$,
	'after deleting the last tripleg, the end time of the trip should be the same with the end time of the neighboring movement tripleg of the deleted tripleg');		

	-- 5. Updating the start time of a tripleg should update the end time of its previous movement tripleg 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:06:00'::timestamp without time zone)::bigint$bd$,
	'modification of from time should propagate to previous non movement tripleg');		

	-- 6. deleting the last tripleg of a trip shifts the trip's end time 
	delete from apiv2.triplegs_inf where tripleg_id = -6;
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -4', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone)::bigint$bd$,
	'modification of to time should propagate to next non movement tripleg');		

	-- 7. 	Prior to deletion, the 6th trip should have 5 triplegs 

	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6', 
	$bd$ select 5::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 5 triplegs');		

	-- 8. 	Prior to deletion, the 6th trip should have 3 movement triplegs 
	
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 1', 
	$bd$ select 3::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 3 movement triplegs');		

	-- 9. 	Prior to deletion, the 6th trip should have 2 non-movement triplegs 
	
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 0', 
	$bd$ select 2::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 2 non-movement triplegs');		

	-- 10. 	deleting a tripleg merges its previous stationary tripleg period with its next stationary tripleg period 
	delete from apiv2.triplegs_inf where tripleg_id = -12;  
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone)::bigint$bd$,
	'after deleting a tripleg, the end time of its previous passive tripleg should be the end time of the next passive tripleg');		

	-- 11. 	After deletion, the 6th trip should have 3 triplegs 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6', 
	$bd$ select 3::bigint$bd$,
	'after deleting a tripleg, the 6th trip should have 3 triplegs');		

	-- 12. 	After deletion, the 6th trip should have 2 movement triplegs 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 1', 
	$bd$ select 2::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 2 movement triplegs');		

	-- 13. 	After deletion, the 6th trip should have 1 non-movement tripleg
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 0', 
	$bd$ select 1::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 1 non-movement triplegs');		
        -- 14. updating the start time of a tripleg is not allowed on the first tripleg of the trip (only tripleg)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 09:33:00'::timestamp without time zone)::bigint , -18)$bd$,
		null,
		null,
		'should alert that the start period of the first tripleg cannot be modified'
		); 

	-- 15. updating the start time of a tripleg is not allowed on the first tripleg of the trip (multiple triplegs)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 16:58:00'::timestamp without time zone)::bigint , -14)$bd$,
		null,
		null,
		'should alert that the start period of the first tripleg cannot be modified'
		); 

	-- 16. updating the end time of a tripleg is not allowed on the last tripleg of the trip (single tripleg)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 09:44:00'::timestamp without time zone)::bigint , -18)$bd$,
		null,
		null,
		'should alert that the end period of the last tripleg cannot be modified'
		); 

	-- 17. updating the end time of a tripleg is not allowed on the last tripleg of the trip (multiple triplegs)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 18:04:00'::timestamp without time zone)::bigint , -10)$bd$,
		null,
		null,
		'should alert that the end period of the last tripleg cannot be modified'
		);  

	-- 18. updating the end time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 17:03:00'::timestamp without time zone)::bigint , -14)$bd$,
	'A end tripleg update of start time should be allowed'
	);

	-- 19. updating the start time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 17:46:00'::timestamp without time zone)::bigint , -10)$bd$,
	'A start tripleg update of end time should be allowed'
	);
	
	-- 20. Updating the end time of a tripleg should update the start time of its next non-movement tripleg 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:03:00'::timestamp without time zone)::bigint$bd$,
	'after updating the end time of the first tripleg, its next non-movement tripleg should be modified');		

	-- 21. Updating the start time of a tripleg should update the end time of its previous movement tripleg 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:46:00'::timestamp without time zone)::bigint$bd$,
	'after updating the start time of the last tripleg, its previous non-movement tripleg should be modified');

SELECT * FROM FINISH();
