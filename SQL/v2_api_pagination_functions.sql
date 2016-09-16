
CREATE OR REPLACE FUNCTION apiv2.ap_get_purposes()
  RETURNS json AS
$BODY$ 
select array_to_json(array_agg((SELECT x FROM (SELECT 0 as accuracy, id, name_ as name, name_sv) x) )) as mode FROM apiv2.purpose_table
$BODY$
  LANGUAGE sql VOLATILE;
COMMENT ON FUNCTION apiv2.ap_get_purposes() is 
'RETURNS AN ARRAY OF THE STUDIED PURPOSES';

-- paginates to the first unannotated trip that the user has to interact with

CREATE OR REPLACE FUNCTION apiv2.pagination_get_next_process(user_id integer)
returns table (trip_id integer, current_trip_start_date bigint,
current_trip_end_date bigint,
previous_trip_end_date bigint, previous_trip_purpose integer, previous_trip_poi_name text,
next_trip_start_date bigint,
purposes json) as
$b$
with first_unprocessed_trip as (
        select * from apiv2.unprocessed_trips
        where user_id = $1
        order by from_time, to_time
        limit 1),
        last_processed_trip as (
        select * from apiv2.processed_trips
        where user_id = $1
        order by from_time desc, to_time desc
        limit 1),
        next_trip_to_process as (
        select * from apiv2.unprocessed_trips
        where user_id = $1
        and trip_id> (select trip_id from first_unprocessed_trip)
        limit 1
        )

select first.trip_id,
        first.from_time as current_trip_start_date, first.to_time as current_trip_end_date,
        last.to_time as previous_trip_end_date, last.purpose_id as last_trip_purpose,
        (select name_ from apiv2.pois where gid = last.destination_poi_id) as previous_trip_poi,
        next.from_time as next_trip_start_date,
        (select * from apiv2.ap_get_purposes()) as purposes
         from first_unprocessed_trip first, last_processed_trip last,
         next_trip_to_process next
 $b$
 LANGUAGE SQL;
COMMENT ON FUNCTION apiv2.pagination_get_next_process(user_id integer) is 
'GETS THE EARLIEST UNANNOTATED TRIP OF THE USER';


CREATE OR REPLACE FUNCTION apiv2.pagination_get_tripleg_with_id(IN tripleg_id integer)
  RETURNS TABLE(triplegid integer, type_of_tripleg smallint, points json, mode json, places json) AS
$BODY$
select tripleg_id as triplegid, type_of_tripleg, 
json_agg(row_to_json((select r from (select l.id, l.lat_ as lat, l.lon_ as lon, l.time_ as time) r))) as points,
(select * from ap_get_probable_modes_of_tripleg_json(tripleg_id)) as modes,
(select * from ap_get_transit_pois_of_tripleg_within_buffer(tl.user_id, tl.from_time, tl.to_time, 200)) as places
from (select * from apiv2.unprocessed_triplegs WHERE tripleg_id = $1) tl,
raw_data.location_table l
where l.time_ between tl.from_time and tl.to_time and l.accuracy_<=50
and l.user_id = tl.user_id
group by tripleg_id, type_of_tripleg, tl.user_id, from_time, to_time
$BODY$
  LANGUAGE sql VOLATILE;;
COMMENT ON FUNCTION apiv2.pagination_get_tripleg_with_id(IN tripleg_id integer) is 
'GETS THE unannotated triplegs of a given trip';