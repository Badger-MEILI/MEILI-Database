select * from plan(3);

-- MANUAL ROLLBACK

ALTER TABLE apiv2.trips_inf DISABLE trigger all; 
ALTER TABLE apiv2.triplegs_inf DISABLE trigger all; 
 
-- DELETE TEST USER 
DELETE FROM raw_data.user_table where id < 0; 

ALTER TABLE apiv2.trips_inf enable trigger all; 
ALTER TABLE apiv2.triplegs_inf enable trigger all;
 
-- 1. DELETE TEST GPS POINTS  should be done by the cascade operation of user_id 
	SELECT results_eq( 'select count(*) from raw_data.location_table where user_id < 0', 'select 0::bigint','deleted user should delete user points');
	
-- 2. DELETE TEST TRIPS should be done by the cascade operation of user_id 
	SELECT results_eq( 'select count(*) from apiv2.trips_inf where user_id < 0', 'select 0::bigint','deleted user should delete user trips');
	
-- 3. DELETE TEST TRIPLEGS should be done by the cascade operation of user_id 
	SELECT results_eq( 'select count(*) from apiv2.triplegs_inf where user_id < 0', 'select 0::bigint','deleted user should delete user triplegs');


SELECT * FROM FINISH();
