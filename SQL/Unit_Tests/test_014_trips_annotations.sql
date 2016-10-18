select * from plan(8);

	-- 1. CHECK THAT THE FOREIGN KEY FOR DESTINATION POI ID IS RESPECTED
	SELECT throws_ok(
		'SELECT update_trip_destination_poi_id FROM apiv2.update_trip_destination_poi_id(-1000, -10);',
		null,
		null,
		'should not be able to insert a reference to a destination poi id that does not exist'
		);
        
        -- 2. CHECK THAT THE FOREIGN KEY FOR PURPOSE ID IS RESPECTED
	SELECT throws_ok(
		'SELECT update_trip_purpose FROM apiv2.update_trip_purpose(-1, -10);',
		null,
		null,
		'should not be able to insert a reference to a purpose id that does not exist'
		);
                
        --3. UPDATING THE DESTINATION POI ID OF AN INVALID TRIP SHOULD RETURN NULL 
         SELECT results_eq(
               'SELECT update_trip_destination_poi_id FROM apiv2.update_trip_destination_poi_id(1, -1000);',
               'select null::boolean',
         'update of destination poi id on invalid trip should be null');         

        --4. UPDATING THE PURPOSE ID OF AN INVALID TRIP SHOULD RETURN NULL
         SELECT results_eq(
               'SELECT update_trip_purpose FROM apiv2.update_trip_purpose(1, -1000);',
               'select null::boolean',
         'update of purpose id on invalid trip should be null');

        --5. UPDATING THE DESTINATION POI ID OF A VALID TRIP SHOULD RETURN TRUE       
	SELECT results_eq( 
        	'SELECT update_trip_destination_poi_id FROM apiv2.update_trip_destination_poi_id(4, -10);', 
	'SELECT TRUE',
	'setting a valid poi of a valid trip should return true');		

        --6. THE UPDATE OF A DESTINATION POI ID SHOULD PERSIST FOR FUTURE SELECTS
        	SELECT results_eq( 
	'SELECT destination_poi_id FROM apiv2.trips_inf where trip_id = -10;', 
	'SELECT 4::bigint',
	'the updated destination poi id should persist in future query selects');		
        --7. UPDATING THE PURPOSE ID OF A VALID TRIP SHOULD RETURN TRUE
        SELECT results_eq( 
	       'SELECT update_trip_purpose FROM apiv2.update_trip_purpose(3, -10);', 
	'SELECT TRUE',
	'setting a valid purpose of a valid trip should return true');		

        --8. THE UPDATE OF A PURPOSE ID SHOULD PERSIST FOR FUTURE SELECTS
        SELECT results_eq( 
	       'SELECT purpose_id FROM apiv2.trips_inf where trip_id = -10;',
	'SELECT 3',
	'the updated purpose id should persist in future query selects');		
        
SELECT * FROM FINISH();
