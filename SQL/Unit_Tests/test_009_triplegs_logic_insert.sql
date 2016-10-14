select * from plan(3);

	--  1. Before insertion , the 10th trip should have 1 tripleg 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -10', 
	$bd$ select 1::bigint$bd$,
	'before inserting a tripleg, the 10th trip should have 1 tripleg');		

	-- 2. Insert new tripleg 
	select lives_ok(
	$bd$select * from apiv2.insert_stationary_tripleg_period_in_trip(
	1000 * extract (epoch from '2016-09-26 09:27:00'::timestamp without time zone)::bigint,
	1000 * extract (epoch from '2016-09-26 09:28:00'::timestamp without time zone)::bigint,
	1, 2, -10)$bd$,
	'Split first trip');

	--  3. After insertion , the 10th trip should have 3 tripleg 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -10', 
	$bd$ select 3::bigint$bd$,
	'after inserting a tripleg, the 10th trip should have 3 triplegs');


SELECT * FROM FINISH();
