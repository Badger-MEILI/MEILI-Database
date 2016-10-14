select * from plan(2); 

	-- 1. check that insert with the same id throws unique key violation
	SELECT throws_ok(
		'INSERT INTO  raw_data.location_table(id, user_id, accuracy_, lat_, lon_, time_) 
		VALUES  (-56, -1, 20, 59.2976978204808, 18.0005932245796, 1000)',
		null,
		null,
		'should get unique violation of primary key constraint on location table'
		);
		
	-- 2. check that insert from an inexistent user_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO raw_data.location_table(id, user_id, accuracy_, lat_, lon_, time_) 
		VALUES  (-200, -100, 20, 59.2976978204808,18.0005932245796, 1000)',
		null,
		null,
		'should get foreign key does not exist constraint on location table'
		);
		
SELECT * FROM FINISH();
