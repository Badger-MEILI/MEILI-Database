select * from plan(3);

	-- 1. cannot update the start time of first tripleg of trip 
	SELECT throws_ok(
		'SELECT * FROM apiv2.update_tripleg_start_time(1000 * extract (epoch from $$2016-09-26 11:00:00$$::timestamp without time zone) :: bigint, -16)',
		null,
		null,
		'should alert that the start time of the tripleg has to be within the current trip'
		);

	-- 2. cannot update the end time of last tripleg of trip 
	SELECT throws_ok(
		'SELECT * FROM apiv2.update_tripleg_end_time(1000 * extract (epoch from $$2016-09-26 13:00:00$$::timestamp without time zone) :: bigint, -16)',
		null,
		null,
		'should alert that the end time of the tripleg has to be within the current trip'
		); 
	
	-- 3. cannot update an active tripleg whose number of points is less than 2 
		SELECT throws_ok(
		'SELECT * FROM apiv2.update_tripleg_start_time(1000 * extract (epoch from $$2016-09-26 12:16:00$$::timestamp without time zone) :: bigint, -16)',
		null,
		null,
		'should alert that the update period does not contain enough locations to form a tripleg'
		); 
		
SELECT * FROM FINISH();
