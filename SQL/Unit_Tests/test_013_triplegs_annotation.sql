select * from plan(8);

	-- 1. CHECK THAT THE FOREIGN KEY FOR TRANSPORTATION POI ID IS RESPECTED
	SELECT throws_ok(
		'SELECT update_tripleg_transition_poi_id FROM apiv2.update_tripleg_transition_poi_id(-1000, -17);',
		null,
		null,
		'should not be able to insert a reference to a transition poi id that does not exist'
		);
        
        -- 2. CHECK THAT THE FOREIGN KEY FOR TRAVEL ID IS RESPECTED
	SELECT throws_ok(
		'SELECT update_tripleg_travel_mode FROM apiv2.update_tripleg_travel_mode(-1, -17);',
		null,
		null,
		'should not be able to insert a reference to a travel mode id that does not exist'
		);
                
        --3. UPDATING THE TRANSPORTATION POI ID OF AN INVALID TRIPLEG SHOULD RETURN NULL 
         SELECT results_eq(
               'SELECT update_tripleg_transition_poi_id FROM apiv2.update_tripleg_transition_poi_id(1, -1000);',
               'select null::boolean',
         'update of transport poi id on invalid tripleg should be null');         

        --4. UPDATING THE TRAVEL MODE ID OF AN INVALID TRIPLEG SHOULD RETURN NULL
         SELECT results_eq(
               'SELECT update_tripleg_travel_mode FROM apiv2.update_tripleg_travel_mode(1, -1000);',
               'select null::boolean',
         'update of travel mode on invalid tripleg should be null');

        --5. UPDATING THE TRANSPORTATION POI ID OF A VALID TRIPLEG SHOULD RETURN TRUE       
	SELECT results_eq( 
        	'SELECT update_tripleg_transition_poi_id FROM apiv2.update_tripleg_transition_poi_id(4, -17);', 
	'SELECT TRUE',
	'setting a valid poi of a valid tripleg should return true');		

        --6. THE UPDATE OF A TRANSPORTATION POI ID SHOULD PERSIST FOR FUTURE SELECTS
        	SELECT results_eq( 
	'SELECT transition_poi_id FROM apiv2.triplegs_inf where tripleg_id = -17;', 
	'SELECT 4::bigint',
	'the updated poi id should persist in future query selects');		

        --7. UPDATING THE TRAVEL MODE ID OF A VALID TRIPLEG SHOULD RETURN TRUE
        SELECT results_eq( 
	       'SELECT update_tripleg_travel_mode FROM apiv2.update_tripleg_travel_mode(3, -17);', 
	'SELECT TRUE',
	'setting a valid travel mode of a valid tripleg should return true');		
        --8. THE UPDATE OF A TRAVEL MODE ID SHOULD PERSIST FOR FUTURE SELECTS
        SELECT results_eq( 
	       'SELECT transportation_type FROM apiv2.triplegs_inf where tripleg_id = -17;',
	'SELECT 3',
	'the updated travel mode should persist in future query selects');		
        
SELECT * FROM FINISH();
