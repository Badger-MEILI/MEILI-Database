select * from plan(2);

	-- 1. inserting a trip will throw no errors 
	SELECT lives_ok(
	$bd$select * from apiv2.insert_stationary_trip_for_user(
	1000 * extract (epoch from '2016-09-26 16:12:00'::timestamp without time zone)::bigint,
	1000 * extract (epoch from '2016-09-26 16:15:00'::timestamp without time zone)::bigint,
	-1)$bd$, 
	'Inserting a new trip should throw no errors');

	-- 2. inserting a trip will increase the number of trips the user has by 2 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.trips_inf where user_id = -1', 
	'select 6::bigint',
	'tripleg time consistency after deletion');		

SELECT * FROM FINISH();
