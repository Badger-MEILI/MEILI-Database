select * from plan(19);

        -- 1. CHECK THAT THE FIRST TRIP A USER CAN ANNOTATE IS THE CORRECT ONE 
        SELECT results_eq(
               'SELECT trip_id FROM apiv2.pagination_get_next_process(-1)',
               'select -10',
         'the first trip annotated by the user should be the correct one');

         -- 2. CHECK THAT THE PREVIOUS TRIP PURPOSE IS NULL 
         SELECT results_eq(
               'SELECT previous_trip_purpose FROM apiv2.pagination_get_next_process(-1)',
               'select null::text',
         'the first trip annotated by the user should not have a previous purpose');
         
         -- 3. CHECK THAT THE PREVIOUS POI NAME IS NULL 
         SELECT results_eq(
               'SELECT previous_trip_poi_name FROM apiv2.pagination_get_next_process(-1)',
               $bd$select ''::text$bd$,
         'the first trip annotated by the user should not have a previous destination');

         -- 4. CHECK THAT THE PREVIOUS TRIP END DATE IS 0 
         SELECT results_eq(
               'SELECT previous_trip_end_date FROM apiv2.pagination_get_next_process(-1)',
               'select 0::bigint',
         'the first trip annotated by the user should not have a previous trip end date');

         -- 5. CHECK THAT THE USER IS ALLOWED TO CONFIRM A FULLY ANNOTATED TRIP 
         SELECT results_eq(
               'SELECT trip_id FROM apiv2.confirm_annotation_of_trip_get_next(-10)',
               'select -8',
         'the next annotated trip should be the correct one');

         -- 6. CHECK THAT THE TRIPLEGS OF THE ANNOTATED TRIP ARE SUCCESSFULLY PASSED TO THE TRIPLEGS GT TABLE 
         SELECT results_eq(
               'SELECT count(*) FROM apiv2.triplegs_inf WHERE trip_id = -10',
               'SELECT count(*) FROM apiv2.triplegs_gt WHERE trip_id = (SELECT trip_id FROM apiv2.trips_gt WHERE trip_inf_id = -10 LIMIT 1)',
         'the number of triplegs inf of a trip should be equal to the number of triplegs_gt of the same trip after annotation');         
         
         -- 7. CHECK THAT THE PREVIOUS TRIP PURPOSE IS 3
         SELECT results_eq(
               'SELECT previous_trip_purpose FROM apiv2.pagination_get_next_process(-1)',
               'select $bd$Business travel$bd$::text',
         'subsequent trips annotated by the user should have the correct previous purpose');         
         -- 8. CHECK THAT THE PREVIOUS POI NAME IS "Hemmet"
         SELECT results_eq(
               'SELECT previous_trip_purpose FROM apiv2.pagination_get_next_process(-1)',
               'select $bd$Business travel$bd$::text',
         'subsequent trips annotated by the user should have the correct previous purpose');

         -- 9. CHECK THAT THE PREVIOUS TRIP END DATE IS 1474884000000
         SELECT results_eq(
               'SELECT previous_trip_end_date FROM apiv2.pagination_get_next_process(-1)',
               'select 1474884000000::bigint',
         'subsequent trips annotated by the user should have the correct previous purpose');

         -- 10. CHECK THAT CONFIRMING AN ANNOTATED TRIP TWICE THROWS AN ERROR
         SELECT throws_ok(
               'SELECT trip_id FROM apiv2.confirm_annotation_of_trip_get_next(-10)',
               null,
               null,
         'annotated trips cannot be confirmed twice');

         -- 11. CHECK THAT THE USER CANNOT CONFIRM A TRIP WITH AN INVALID OR MISSING PURPOSE         
         SELECT throws_ok(
               'SELECT trip_id FROM apiv2.confirm_annotation_of_trip_get_next(-8)',
               null,
               null,
         'trips without a purpose cannot be confirmed');             

         -- 12. USER CAN ADD A PURPOSE
	SELECT results_eq( 
        	'SELECT update_trip_purpose FROM apiv2.update_trip_purpose(1, -8);', 
                'SELECT TRUE',
	'setting a valid poi of a valid trip should return true');		

         -- 13. CHECK THAT THE USER CANNOT CONFIRM A TRIP WITH AN INVALID OR MISSING DESTINATION ID 
         
         SELECT throws_ok(
               'SELECT trip_id FROM apiv2.confirm_annotation_of_trip_get_next(-8)',
               null,
               null,
         'trips without a destination cannot be confirmed');             
         
         -- 14. USER CAN ADD A DESTINATION 
         SELECT results_eq( 
        	'SELECT update_trip_destination_poi_id FROM apiv2.update_trip_destination_poi_id(10, -8);', 
	        'SELECT TRUE',
	'setting a valid poi of a valid trip should return true');		
         
         -- 15. CHECK THAT THE USER CANNOT CONFIRM A TRIP THAT CONTAINS TRIPLEGS THAT ARE NOT ANNOTATED 
         SELECT throws_ok(
               'SELECT trip_id FROM apiv2.confirm_annotation_of_trip_get_next(-8)',
               null,
               null,
         'trips without tripleg annotations cannot be confirmed');
         
         -- 16. USER CAN ANNOTATE TRIPLEGS 
         SELECT results_eq( 
	       'SELECT update_tripleg_travel_mode FROM apiv2.update_tripleg_travel_mode(5, -16);', 
               'SELECT TRUE',
	'setting a valid travel mode of a valid tripleg should return true');
         
         -- 17. THE TRIP CAN BE CONFIRMED AFTER ALL ANNOTATIONS ARE SPECIFIED
         SELECT results_ne( 
	       'SELECT trip_id FROM apiv2.confirm_annotation_of_trip_get_next(-8);', 
               'SELECT -8',
	'action of confirming a trip should return the next trip to be annotated');
        
         -- 18. PAGINATION RESUMES WITH THE CORRECT TRIP
         SELECT results_ne( 
	       'SELECT trip_id FROM apiv2.pagination_get_next_process(-1);', 
               'SELECT -8',
	'action of confirming a trip should return the next trip to be annotated (does not return previous trip)');

        --19. PAGINATION RESUMES WITH THE CORRECT TRIP P2
        SELECT results_ne( 
	       'SELECT trip_id FROM apiv2.pagination_get_next_process(-1);', 
               'SELECT -10',
	'action of confirming a trip should return the next trip to be annotated (does not return first trip)');

SELECT * FROM FINISH();
