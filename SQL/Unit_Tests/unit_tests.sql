select * from plan(73);

DELETE FROM raw_data.user_table where id < 0; 

-- INSERT TEST USER 
INSERT INTO raw_data.user_table VALUES (-1, 'foo@user.com', crypt('foopassword', gen_salt('bf',8)), 'foo_phone', 'foo_os');

	-- 1. CHECK FOR CORRECT USER ID
	SELECT set_eq(
		'select * from raw_data.login_user($bd$foo@user.com$bd$, $bd$foopassword$bd$)',
		'select id from raw_data.user_table where username = $bd$foo@user.com$bd$',
		'checking if the correct user id is returned by the login function');
	-- 2. CHECK THAT THE WRONG PASSWORD RETURNS AN EMPTY RESULT
	SELECT bag_hasnt(
		'select * from raw_data.login_user($bd$foo@user.com$bd$, $bd$wrongfoopassword$bd$)', 
		'select id from raw_data.user_table where username = $bd$foo@user.com$bd$',
		'wrong password should return empty result');

	-- 3. CHECK THAT THE PRIMARY KEY ON USER TABLE IS RESPECTED
	SELECT throws_ok(
		'INSERT INTO raw_data.user_table VALUES (-1, $bd$secondfoo@user.com$bd$, crypt($bd$foopassword$bd$, gen_salt($bd$bf$bd$,8)), $bd$foo_phone$bd$, $bd$foo_os$bd$);',
		null,
		null,
		'should get unique violation of primary key constraint'
		);

	
-- INSERT TEST GPS POINTS  

INSERT INTO raw_data.location_table(id, user_id, accuracy_, lat_, lon_, time_) VALUES
-- first_trip between 09:20 and 10:00
-- first_trip -> first movement tripleg: walked from  09:20 to 09:25
(-100, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:22:40'::timestamp without time zone)),
(-99, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:23:00'::timestamp without time zone)),
(-98, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:23:50'::timestamp without time zone)),
(-97, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:24:00'::timestamp without time zone)),
(-96, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:25:00'::timestamp without time zone)),
-- first_trip -> first stationary tripleg period: waited for bus between 09:25 and 09:30
(-95, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:28:00'::timestamp without time zone)),
-- first_trip -> last movement tripleg: took the bus between 09:30 and 10:00 
(-94, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:31:00'::timestamp without time zone)),
(-93, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:34:00'::timestamp without time zone)),
(-92, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:39:00'::timestamp without time zone)),
(-91, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:40:00'::timestamp without time zone)),
(-90, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:41:00'::timestamp without time zone)),
(-89, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:42:00'::timestamp without time zone)),
(-88, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:55:00'::timestamp without time zone)),
(-87, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone)),
-- first stationary trip period: stayed at home between 10:00 and 12:00
(-86, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 10:20:00'::timestamp without time zone)),
(-85, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 11:00:00'::timestamp without time zone)),
(-84, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 11:30:00'::timestamp without time zone)),
(-83, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone)),
-- second trip: first and only tripleg walked between 12:00 and 12:20
(-82, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:05:00'::timestamp without time zone)),
(-81, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:10:00'::timestamp without time zone)),
(-80, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:15:00'::timestamp without time zone)),
(-719, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone)), 
-- second stationary trip period: stayed at work between 12:20 and 17:00 without any GPS points or triplegs recorded 
-- third trip: first tripleg walked between 17:00 and 17:05
(-79, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone)), 
(-78, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:01:00'::timestamp without time zone)), 
(-77, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:03:00'::timestamp without time zone)), 
(-76, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:05:00'::timestamp without time zone)), 
-- third trip: first stationary tripleg period: waited for the tram between 17:05 and 17:07 without any GPS points recorded 
-- third trip: took the tram between 17:07 and 17:42 
(-75, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:07:00'::timestamp without time zone)), 
(-74, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:17:00'::timestamp without time zone)), 
(-73, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:20:00'::timestamp without time zone)), 
(-72, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:22:00'::timestamp without time zone)), 
(-71, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:30:00'::timestamp without time zone)), 
(-70, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:35:00'::timestamp without time zone)), 
(-69, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:40:00'::timestamp without time zone)), 
(-68, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:47:00'::timestamp without time zone)), 
-- third trip: second stationary tripleg switched to walking between 17:47 and 17:48 
(-67, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:47:30'::timestamp without time zone)), 
-- third trip: third tripleg walked between 17:48 and 18:00
(-66, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone)), 
(-65, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone)), 
-- third stationary trip period: stayed at home between 18:00 and 19:00
(-64, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 18:30:00'::timestamp without time zone)), 
-- fourth and last trip: firs tripleg walked between 19:00 and 19:10 
(-63, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone)), 
(-62, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:05:00'::timestamp without time zone)), 
-- fourth and last trip: first stationary tripleg switched to car between 19:10 and 19:10 
-- fourth and last trip: second and last tripleg: drove car between 19:10 and 19:20 
(-61, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone)), 
(-60, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:11:00'::timestamp without time zone)), 
(-59, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:12:00'::timestamp without time zone)), 
(-58, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:15:00'::timestamp without time zone)), 
(-57, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:17:00'::timestamp without time zone)), 
(-56, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:20:00'::timestamp without time zone));

	-- 4. check that insert with the same id throws unique key violation
	SELECT throws_ok(
		'INSERT INTO  raw_data.location_table(id, user_id, accuracy_, lat_, lon_, time_) 
		VALUES  (-56, -1, 20, 59.2976978204808, 18.0005932245796, 1000)',
		null,
		null,
		'should get unique violation of primary key constraint on location table'
		);
		
	-- 5. check that insert from an inexistent user_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO raw_data.location_table(id, user_id, accuracy_, lat_, lon_, time_) 
		VALUES  (-200, -100, 20, 59.2976978204808,18.0005932245796, 1000)',
		null,
		null,
		'should get foreign key does not exist constraint on location table'
		);
		
-- INSERT TEST TRIPS 

-- first trip between 09:20 and 10:00
insert into apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
VALUES 
-- first trip between 09:20 and 10:00
(-10, -1, 1000 * extract (epoch from '2016-09-26 09:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1),
-- first stationary trip period: stayed at home between 10:00 and 12:00
(-9, -1, 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 0),
-- second trip: between 12:00 and 12:20
(-8, -1, 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1),
-- second stationary trip period: stayed at work between 12:20 and 17:00 without any GPS points or triplegs recorded 
(-7, -1, 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 0),
-- third trip: between 17:00 and 18:00
(-6, -1, 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1),
-- third stationary trip period: stayed at home between 18:00 and 19:00
(-5, -1, 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 0),
-- fourth trip: between 19:00 and 19:20
(-4, -1, 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:20:00'::timestamp without time zone), 1);

	-- 6. check that insert with the same id throws unique key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
		VALUES  (-10, -1, 1000, 1000, 1)',
		null,
		null,
		'should get unique violation of primary key constraint on trips_inf table'
		);
		
	-- 7. check that insert from an inexistent user_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
		VALUES  (-100, -10, 1000, 1000, 1)',
		null,
		null,
		'should get foreign key does not exist constraint on trips_inf table'
		);

	-- 8. check that invalid time periods are detected 
	SELECT throws_ok(
		'INSERT INTO apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
		VALUES  (-100, -1, 2000, 1000, 1)',
		null,
		null,
		'should throw check constraint error because start time is later than end time'
		);
	
-- INSERT TEST TRIPLEGS 
INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
VALUES
-- first_trip (-10) -> first movement tripleg: walked from  09:20 to 09:25 
(-20, -10, -1, 1000 * extract (epoch from '2016-09-26 09:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 09:25:00'::timestamp without time zone), 1),
-- first_trip (-10) -> first stationary tripleg period: waited for bus between 09:25 and 09:30
(-19, -10, -1, 1000 * extract (epoch from '2016-09-26 09:25:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 09:30:00'::timestamp without time zone), 0),
-- first_trip (-10) -> last movement tripleg: took the bus between 09:30 and 09:40 
(-18, -10, -1, 1000 * extract (epoch from '2016-09-26 09:30:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1),
-- first stationary trip period (-9): stayed at home between 10:00 and 12:00
(-17, -9, -1, 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 1),
-- second trip (-8): first and only tripleg walked between 12:00 and 12:20
(-16, -8, -1, 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1),
-- second stationary trip period (-7): stayed at work between 12:20 and 17:00 without any GPS points or triplegs recorded 
(-15, -7, -1, 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 0),
-- third trip (-6): first tripleg walked between 17:00 and 17:05
(-14, -6, -1, 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:05:00'::timestamp without time zone), 1),
-- third trip (-6): first stationary tripleg period: waited for the tram between 17:05 and 17:07 without any GPS points recorded 
(-13, -6, -1, 1000 * extract (epoch from '2016-09-26 17:05:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:07:00'::timestamp without time zone), 0),
-- third trip (-6): took the tram between 17:07 and 17:47
(-12, -6, -1, 1000 * extract (epoch from '2016-09-26 17:07:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:47:00'::timestamp without time zone), 1),
-- third trip (-6): second stationary tripleg switched to walking between 17:47 and 17:48 
(-11, -6, -1, 1000 * extract (epoch from '2016-09-26 17:47:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone), 0),
-- third trip (-6): third tripleg walked between 17:48 and 18:00
(-10, -6, -1, 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1),
-- third stationary trip period (-5): stayed at home between 18:00 and 19:00
(-9, -5, -1, 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 1),
-- fourth and last trip (-4): firs tripleg walked between 19:00 and 19:10 
(-8, -4, -1, 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 1),
-- fourth and last trip (-4): first stationary tripleg switched to car between 19:10 and 19:10 
(-7, -4, -1, 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 0),
-- fourth and last trip (-4): second and last tripleg: drove car between 19:10 and 19:20 
(-6, -4, -1, 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:20:00'::timestamp without time zone), 1); 


	-- 9. check that insert with the same id throws unique key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-20, -10, -1, 1000, 1000, 1)',
		null,
		null,
		'should get unique violation of primary key constraint on trips_inf table'
		);
		
	-- 10. check that insert from an inexistent user_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-100, -10, -10, 1000, 1000, 1)',
		null,
		null,
		'should get user foreign key does not exist constraint on trips_inf table'
		);

	-- 11. check that insert from an inexistent trip_id throws a foreign key violation
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-100, -140, -1, 1000, 1000, 1)',
		null,
		null,
		'should get trip foreign key does not exist constraint on trips_inf table'
		);
		
	-- 12. check that invalid time periods are detected 
	SELECT throws_ok(
		'INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
		VALUES  (-120, -10, -1, 2000, 1000, 1)',
		null,
		null,
		'should throw check constraint error because start time is later than end time'
		);
		
	-- 13. cannot update the start time of first tripleg of trip 
	SELECT throws_ok(
		'SELECT * FROM apiv2.update_tripleg_start_time(1000 * extract (epoch from $$2016-09-26 11:00:00$$::timestamp without time zone) :: bigint, -16)',
		null,
		null,
		'should alert that the start time of the tripleg has to be within the current trip'
		);

	-- 14. cannot update the end time of last tripleg of trip 
	SELECT throws_ok(
		'SELECT * FROM apiv2.update_tripleg_end_time(1000 * extract (epoch from $$2016-09-26 13:00:00$$::timestamp without time zone) :: bigint, -16)',
		null,
		null,
		'should alert that the end time of the tripleg has to be within the current trip'
		); 
	
	-- 15. cannot update an active tripleg whose number of points is less than 2 
		SELECT throws_ok(
		'SELECT * FROM apiv2.update_tripleg_start_time(1000 * extract (epoch from $$2016-09-26 12:16:00$$::timestamp without time zone) :: bigint, -16)',
		null,
		null,
		'should alert that the update period does not contain enough locations to form a tripleg'
		); 
		
	-- 16. cannot delete the only tripleg of a trip 
		SELECT throws_ok(
		'SELECT * FROM apiv2.delete_tripleg(-16)',
		null,
		null,
		'should alert that it is not possible to delete the only tripleg of the trip'
		); 

	-- 17. deleting the first tripleg of a trip shifts the trip's start time 
	delete from apiv2.triplegs_inf where tripleg_id = -20;
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -10', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 09:30:00'::timestamp without time zone)::bigint$bd$,
	'after deleting the first tripleg, the start time of the trip should be the same with the start time of the neighboring movement tripleg of the deleted tripleg');

	-- 19. updating the end time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 17:43:00'::timestamp without time zone)::bigint , -12)$bd$,
	'A mid tripleg update of start time should be allowed'
	);

	-- 20. updating the start time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 17:06:00'::timestamp without time zone)::bigint , -12)$bd$,
	'A mid tripleg update of end time should be allowed'
	);
	
	-- 21. Updating the end time of a tripleg should update the start time of its next non-movement tripleg 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -11', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:43:00'::timestamp without time zone)::bigint$bd$,
	'after deleting the last tripleg, the end time of the trip should be the same with the end time of the neighboring movement tripleg of the deleted tripleg');		

	-- 22. Updating the start time of a tripleg should update the end time of its previous movement tripleg 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:06:00'::timestamp without time zone)::bigint$bd$,
	'modification of from time should propagate to previous non movement tripleg');		

	-- 23. deleting the last tripleg of a trip shifts the trip's end time 
	delete from apiv2.triplegs_inf where tripleg_id = -6;
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -4', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone)::bigint$bd$,
	'modification of to time should propagate to next non movement tripleg');		

	-- 24. 	Prior to deletion, the 6th trip should have 5 triplegs 

	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6', 
	$bd$ select 5::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 5 triplegs');		

	-- 25. 	Prior to deletion, the 6th trip should have 3 movement triplegs 
	
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 1', 
	$bd$ select 3::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 3 movement triplegs');		

	-- 26. 	Prior to deletion, the 6th trip should have 2 non-movement triplegs 
	
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 0', 
	$bd$ select 2::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 2 non-movement triplegs');		

	-- 27. 	deleting a tripleg merges its previous stationary tripleg period with its next stationary tripleg period 
	delete from apiv2.triplegs_inf where tripleg_id = -12;  
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone)::bigint$bd$,
	'after deleting a tripleg, the end time of its previous passive tripleg should be the end time of the next passive tripleg');		

	-- 28. 	After deletion, the 6th trip should have 3 triplegs 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6', 
	$bd$ select 3::bigint$bd$,
	'after deleting a tripleg, the 6th trip should have 3 triplegs');		

	-- 29. 	After deletion, the 6th trip should have 2 movement triplegs 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 1', 
	$bd$ select 2::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 2 movement triplegs');		

	-- 30. 	After deletion, the 6th trip should have 1 non-movement tripleg
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -6 and type_of_tripleg = 0', 
	$bd$ select 1::bigint$bd$,
	'before deleting a tripleg, the 6th trip should have 1 non-movement triplegs');		
	
	-- 31. updating the start time of a tripleg is not allowed on the first tripleg of the trip (only tripleg)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 09:33:00'::timestamp without time zone)::bigint , -18)$bd$,
		null,
		null,
		'should alert that the start period of the first tripleg cannot be modified'
		); 

	-- 32. updating the start time of a tripleg is not allowed on the first tripleg of the trip (multiple triplegs)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 16:58:00'::timestamp without time zone)::bigint , -14)$bd$,
		null,
		null,
		'should alert that the start period of the first tripleg cannot be modified'
		); 

	-- 33. updating the end time of a tripleg is not allowed on the last tripleg of the trip (single tripleg)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 09:44:00'::timestamp without time zone)::bigint , -18)$bd$,
		null,
		null,
		'should alert that the end period of the last tripleg cannot be modified'
		); 

	-- 34. updating the end time of a tripleg is not allowed on the last tripleg of the trip (multiple triplegs)
	SELECT throws_ok(
		$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 18:04:00'::timestamp without time zone)::bigint , -10)$bd$,
		null,
		null,
		'should alert that the end period of the last tripleg cannot be modified'
		);  

	-- 35. updating the end time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_end_time(1000 * extract (epoch from '2016-09-26 17:03:00'::timestamp without time zone)::bigint , -14)$bd$,
	'A end tripleg update of start time should be allowed'
	);

	-- 36. updating the start time of a middle tripleg from a multiple tripleg trip should be allowed
	select lives_ok(
	$bd$select * from apiv2.update_tripleg_start_time(1000 * extract (epoch from '2016-09-26 17:46:00'::timestamp without time zone)::bigint , -10)$bd$,
	'A start tripleg update of end time should be allowed'
	);
	
	-- 37. Updating the end time of a tripleg should update the start time of its next non-movement tripleg 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:03:00'::timestamp without time zone)::bigint$bd$,
	'after updating the end time of the first tripleg, its next non-movement tripleg should be modified');		

	-- 38. Updating the start time of a tripleg should update the end time of its previous movement tripleg 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -13', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 17:46:00'::timestamp without time zone)::bigint$bd$,
	'after updating the start time of the last tripleg, its previous non-movement tripleg should be modified');		

	-- 39. updating the start time of a trip will result in updating the start time of the only tripleg of that trip 	
	select lives_ok($bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 09:24:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -10;$bd$, 
	'Update of the start time of a trip updates the start time of its only tripleg'); 

	-- 40. updating the start time of a trip will result in updating the start time of the only tripleg of that trip 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -18', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 09:24:00'::timestamp without time zone)::bigint$bd$,
	'trip start time update induces tripleg start time update');		
	
	-- 41. updating the start time of a trip will result in updating the start time of the first tripleg of that trip 
	select lives_ok($bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the start time of a trip updates the start time of its first tripleg'); 

	-- 42. updating the start time of a trip will result in updating the start time of the first tripleg of that trip 
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -14', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint$bd$,
	'trip start time update induces tripleg start time update');		

	-- 43. updating the end time of a trip will result in updating the end time of the only tripleg of that trip 	
	select lives_ok($bd$UPDATE apiv2.trips_inf set to_time = (select 1000 * extract (epoch from '2016-09-26 20:40:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -4;$bd$, 
	'Update of the end time of a trip updates the end time of its only tripleg'); 

	-- 44. updating the end time of a trip will result in updating the end time of the only tripleg of that trip 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -8', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 20:40:00'::timestamp without time zone)::bigint$bd$,
	'trip end time update induces tripleg end time update');		
	
	-- 45. updating the end time of a trip will result in updating the end time of the last tripleg of that trip 
	select lives_ok($bd$UPDATE apiv2.trips_inf set to_time = (select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the end time of a trip updates the end time of its last tripleg'); 

	-- 46. updating the end time of a trip will result in updating the end time of the last tripleg of that trip 
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -10', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint$bd$,
	'trip end time update induces tripleg end time update');		

	--  47. Before insertion , the 10th trip should have 1 tripleg 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -10', 
	$bd$ select 1::bigint$bd$,
	'before inserting a tripleg, the 10th trip should have 1 tripleg');		

	-- 47. Insert new tripleg 
	select lives_ok(
	$bd$select * from apiv2.insert_stationary_tripleg_period_in_trip(
	1000 * extract (epoch from '2016-09-26 09:27:00'::timestamp without time zone)::bigint,
	1000 * extract (epoch from '2016-09-26 09:28:00'::timestamp without time zone)::bigint,
	1, 2, -10)$bd$,
	'Split first trip');

	--  48. After insertion , the 10th trip should have 3 tripleg 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.triplegs_inf where trip_id = -10', 
	$bd$ select 3::bigint$bd$,
	'after inserting a tripleg, the 10th trip should have 3 triplegs');
	
	-- 49. updating the start time of a trip will result in updating the end time of the previous stationary trip period
	-- Relation to 41 
	/*select lives_ok($bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the start time of a trip updates the start time of its first tripleg');*/
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:51:00'::timestamp without time zone)::bigint$bd$,
	'trip start time update induces previous non movement trip end time update');		
	
	-- 50. updating the end time of a trip will result in updating the end time of the next stationary trip period
	-- Relation to 45
	/* select lives_ok($bd$UPDATE apiv2.trips_inf set to_time = (select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$, 
	'Update of the end time of a trip updates the end time of its last tripleg'); */
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -5', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 18:12:00'::timestamp without time zone)::bigint$bd$,
	'trip end time update induces next non movement trip start time update');		
	
	-- 51. cannot update the start time of a trip more than the end time of a previous active trip  

	SELECT throws_ok(
	$bd$UPDATE apiv2.trips_inf set from_time = (select 1000 * extract (epoch from '2016-09-26 10:12:00'::timestamp without time zone)::bigint)
	WHERE trip_id = -6;$bd$,
	null,
	null,
	'Cannot overlap previous trip movement periods'
	); 
		
	-- 52. updating the end time of a trip will result in deleting all the trips that fall within the period [old.end_time and new.end_time] and not throw errors
	SELECT lives_ok(
	$bd$SELECT * FROM apiv2.update_trip_end_time(1000 * extract (epoch from '2016-09-26 23:12:00'::timestamp without time zone)::bigint,
	-6)$bd$, 
	'Cannot overlap previous trip movement periods'
	); 
	
	-- 53 [frozen]. updating the end time of a trip will delete next non-movement trip period if overlapping 
	-- SELECT is_empty( 
	-- 'SELECT trip_id from apiv2.trips_inf where trip_id = -5',  
	-- 'next non-movement trip period should not exist');		

	-- 54. updating the end time of a trip will delete next movement trip period if overlapping 
	SELECT is_empty( 
	'SELECT trip_id from apiv2.trips_inf where trip_id = -4',  
	'next trip should not exist');		
	
	-- 55. updating the end time of a trip that overlaps a neighboring active trip will update the start_time of the neighboring trip to the suggested end_time, which will also trigger the update of the tripleg's time
	SELECT lives_ok(
	$bd$SELECT * FROM apiv2.update_trip_end_time(
	1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint,
	-8)$bd$, 
	'Cannot overlap previous trip movement periods'
	); 

	-- 56. next non movement trip period should exist and have the start time equal to the updated end time of trip 6
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'next non movement trip exists and has correct start time');		

	-- 57. next non movement trip period should exist and have the end time equal to the updated end time of trip 6
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'next non movement trip exists and has correct start time');		

	-- 58. next movement trip period should exist and have the start time equal to the updated end time of trip 6
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -6', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'next non movement trip exists and has correct start time');		

	-- 59. deleting a trip with multiple triplegs is allowed 
	SELECT lives_ok(
	$bd$DELETE from apiv2.trips_inf where trip_id = -6 $bd$, 
	'The trip should be deleted'
	); 

	-- 60. deleted trip sould not exist
	SELECT is_empty( 
	'SELECT trip_id from apiv2.trips_inf where trip_id = -6',  
	'delete trip should not exist');		

	-- 61. deleted trip next non movement period sould not exist
	SELECT is_empty( 
	'SELECT trip_id from apiv2.trips_inf where trip_id = -5',  
	'delete trip next non movement period should not exist');		

	-- 62. previous neighboring trip of deleted trip should have the same start time as before 
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -8', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone)::bigint$bd$,
	'previous neighboring trip of deleted trip should have the same start time as before');		

	-- 63. previous neighboring trip of deleted trip should have the same end time as before 
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -8', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'previous neighboring trip of deleted trip should have the same end time as before');			

	-- 64. previous non movement neighboring trip of deleted trip should have the same start time as before 
	SELECT results_eq( 
	'SELECT from_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'previous non movement neighboring trip of deleted trip should have the same start time as before ');			

	-- 65. previous non movement neighboring trip of deleted trip should have the end time equal to that of the deleted trip
	SELECT results_eq( 
	'SELECT to_time from apiv2.trips_inf where trip_id = -7', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 23:12:00'::timestamp without time zone)::bigint$bd$,
	'previous non movement neighboring trip of deleted trip should have the end time equal to that of the deleted trip');			
	
	-- 66. deleting a trip should delete all the triplegs belonging to that trip 
	SELECT is_empty( 
	'SELECT tripleg_id from apiv2.triplegs_inf where trip_id = -6',  
	'deleting a trip should delete all the triplegs belonging to that trip ');		

	-- 67. deleting a trip will merge its previous and next passive triplegs into one - from_time
	SELECT results_eq( 
	'SELECT from_time from apiv2.triplegs_inf where tripleg_id = -16', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone)::bigint$bd$,
	'tripleg belonging to the previous neighboring trip of deleted trip should have the same start time as before');		

	-- 68. deleting a trip will merge its previous and next passive triplegs into one - to_time
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -16', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 16:53:00'::timestamp without time zone)::bigint$bd$,
	'tripleg belonging to the previous neighboring trip of deleted trip should have the same end time with as before');		

	-- 69. deleting a trip will merge its previous and next passive triplegs into one - to_time
	SELECT results_eq( 
	'SELECT to_time from apiv2.triplegs_inf where tripleg_id = -15', 
	$bd$ select 1000 * extract (epoch from '2016-09-26 23:12:00'::timestamp without time zone)::bigint$bd$,
	'tripleg time consistency after deletion');		

	-- 70. inserting a trip will throw no errors 
	SELECT lives_ok(
	$bd$select * from apiv2.insert_stationary_trip_for_user(
	1000 * extract (epoch from '2016-09-26 16:12:00'::timestamp without time zone)::bigint,
	1000 * extract (epoch from '2016-09-26 16:15:00'::timestamp without time zone)::bigint,
	-1)$bd$, 
	'Inserting a new trip should throw no errors');

	-- 71. inserting a trip will increase the number of trips the user has by 2 
	SELECT results_eq( 
	'SELECT count(*) from apiv2.trips_inf where user_id = -1', 
	'select 6::bigint',
	'tripleg time consistency after deletion');		
-- MANUAL ROLLBACK

ALTER TABLE apiv2.trips_inf DISABLE trigger all; 
ALTER TABLE apiv2.triplegs_inf DISABLE trigger all; 
 
-- DELETE TEST USER 
DELETE FROM raw_data.user_table where id < 0; 

ALTER TABLE apiv2.trips_inf enable trigger all; 
ALTER TABLE apiv2.triplegs_inf enable trigger all;
 
-- 37. DELETE TEST GPS POINTS  should be done by the cascade operation of user_id 
	SELECT results_eq( 'select count(*) from raw_data.location_table where user_id < 0', 'select 0::bigint','deleted user should delete user points');
	
-- 38. DELETE TEST TRIPS should be done by the cascade operation of user_id 
	SELECT results_eq( 'select count(*) from apiv2.trips_inf where user_id < 0', 'select 0::bigint','deleted user should delete user trips');
	
-- 39. DELETE TEST TRIPLEGS should be done by the cascade operation of user_id 
	SELECT results_eq( 'select count(*) from apiv2.triplegs_inf where user_id < 0', 'select 0::bigint','deleted user should delete user triplegs');
	
SELECT * FROM FINISH();