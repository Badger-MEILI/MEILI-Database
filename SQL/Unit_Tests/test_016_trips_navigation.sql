select * from plan(7);

        -- 1. CHECK THAT THE FUNCTION TO NAVIGATE TO NEXT TRIP RETURNS THE CORRECT RESULT FOR THE FIRST ANNOTATED TRIP
        SELECT results_eq(
               'select trip_id from apiv2.pagination_navigate_to_next_trip(-1,
               (select trip_id from apiv2.trips_gt where trip_inf_id = -10))',
               'select trip_id from apiv2.trips_gt where trip_inf_id = -8',
         'the function to navigate to the next trip should return the correct trip id');

        -- 2. CHECK THAT THE FUNCTION TO NAVIGATE TO NEXT TRIP RETURNS THE CORRECT STATUS FOR THE FIRST ANNOTATED TRIP
        SELECT results_eq(
               'select status from apiv2.pagination_navigate_to_next_trip(-1,
               (select trip_id from apiv2.trips_gt where trip_inf_id = -10))',
               'select $bd$already_annotated$bd$::text',
         'the function to navigate to the next trip should return the correct status');

        -- 3. CHECK THAT THE FUNCTION TO NAVIGATE TO NEXT TRIP RETURNS THE CORRECT RESULT FOR THE SECOND ANNOTATED TRIP
        SELECT results_eq(
               'select trip_id from apiv2.pagination_navigate_to_next_trip(-1,
               (select trip_id from apiv2.trips_gt where trip_inf_id = -8))',
               'select t2.trip_id from apiv2.trips_inf t1, apiv2.trips_inf t2 where t1.trip_id = -8 and t1.user_id = t2.user_id and t2.from_time>=t1.to_time and t2.type_of_trip=1 order by t2.from_time, t2.to_time limit 1',
         'the function to navigate to the next trip should return the correct trip id 2');

        -- 4. CHECK THAT THE FUNCTION TO NAVIGATE TO NEXT TRIP FLAGS THAT THE LAST TRIP NEEDS AN ANNOTATION 
        SELECT results_eq(
               'select status from apiv2.pagination_navigate_to_next_trip(-1,
               (select trip_id from apiv2.trips_gt where trip_inf_id = -8))',
               'select $bd$needs_annotation$bd$::text',
         'the function to navigate to the next trip should flag when it reached the end'); 
         
        -- 5. CHECK THAT THE FUNCTION TO NAVIGATE TO THE PREVIOUS ANNOTATED TRIP RETURNS THE CORRECT ID 
        SELECT results_eq(
               'select trip_id from apiv2.pagination_navigate_to_previous_trip(-1,
               (select trip_id from apiv2.trips_gt where trip_inf_id = -8))',
               'select trip_id from apiv2.trips_gt where trip_inf_id = -10',
         'the function to navigate to the previous trip should return the correct trip id');
         
        -- 6. CHECK THAT THE FUNCTION TO NAVIGATE TO THE PREVIOUS ANNOTATED TRIP RETURNS THE CORRECT STATUS
        SELECT results_eq(
               'select status from apiv2.pagination_navigate_to_previous_trip(-1,
               (select trip_id from apiv2.trips_gt where trip_inf_id = -8))',
               'select $bd$already_annotated$bd$::text',
         'the function to navigate to the previous trip should return the correct trip status');

        -- 7. CHECK THAT THE FUNCTION TO NAVIGATE TO THE PREVIOUS ANNOTATED TRIP DOES NOT GO BEYOND THE FIRST ANNOTATED TRIP
        SELECT is_empty(
               'select *  from apiv2.pagination_navigate_to_previous_trip(-1,
               (select trip_id from apiv2.trips_gt where trip_inf_id = -10))',
         'the function to navigate to the previous trip should return an empty result set if it reaches the first trip');

SELECT * FROM FINISH();
