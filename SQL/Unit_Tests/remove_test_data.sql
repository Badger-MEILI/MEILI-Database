-- MANUAL ROLLBACK

ALTER TABLE apiv2.trips_inf DISABLE trigger all; 
ALTER TABLE apiv2.triplegs_inf DISABLE trigger all; 
 
-- DELETE TEST USER 
DELETE FROM raw_data.user_table where id < 0; 

ALTER TABLE apiv2.trips_inf enable trigger all; 
ALTER TABLE apiv2.triplegs_inf enable trigger all;
