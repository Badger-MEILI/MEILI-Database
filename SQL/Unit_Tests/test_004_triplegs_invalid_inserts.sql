select * from plan(4);

	-- 1. check that insert with the same id throws unique key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-20, -10, -1, 1000, 1000, 1)',
		null,
		null,
		'should get unique violation of primary key constraint on trips_inf table'
		);
		
	-- 2. check that insert from an inexistent user_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-100, -10, -10, 1000, 1000, 1)',
		null,
		null,
		'should get user foreign key does not exist constraint on trips_inf table'
		);

	-- 3. check that insert from an inexistent trip_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-100, -140, -1, 1000, 1000, 1)',
		null,
		null,
		'should get trip foreign key does not exist constraint on trips_inf table'
		);
		
	-- 4. check that invalid time periods are detected 
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-120, -10, -1, 2000, 1000, 1)',
		null,
		null,
		'should throw check constraint error because start time is later than end time'
		);

SELECT * FROM FINISH();
