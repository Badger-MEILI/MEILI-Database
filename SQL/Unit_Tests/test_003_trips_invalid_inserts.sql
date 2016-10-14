select * from plan(3);

	-- 1. check that insert with the same id throws unique key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
		VALUES  (-10, -1, 1000, 1000, 1)',
		null,
		null,
		'should get unique violation of primary key constraint on trips_inf table'
		);
		
	-- 2. check that insert from an inexistent user_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
		VALUES  (-100, -10, 1000, 1000, 1)',
		null,
		null,
		'should get foreign key does not exist constraint on trips_inf table'
		);

	-- 3. check that invalid time periods are detected 
	SELECT throws_ok(
		'INSERT INTO apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
		VALUES  (-100, -1, 2000, 1000, 1)',
		null,
		null,
		'should throw check constraint error because start time is later than end time'
		);

SELECT * FROM FINISH();
