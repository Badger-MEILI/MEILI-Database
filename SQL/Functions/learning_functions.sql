CREATE SCHEMA IF NOT EXISTS learning_processes; 
 
CREATE MATERIALIZED VIEW IF NOT EXISTS learning_processes.summary_of_mode_overall AS 
 SELECT foo.transportation_type,
    avg(foo.point_avg_speed) AS point_avg_speed,
    avg(foo.point_avg_acc) AS point_avg_acc,
    avg(foo.point_avg_steps) AS point_avg_steps,
    avg(foo.point_avg_dist) AS point_avg_dist,
    avg(foo.travelled_distance) AS travelled_distance,
    avg(foo.duration_of_tripleg) AS duration_of_tripleg,
    avg(foo.speed_overall_of_tripleg) AS speed_overall_of_tripleg,
    current_date as last_refreshed
   FROM ( SELECT l2.user_id,
            l2.transportation_type,
            avg(l1.speed_) AS point_avg_speed,
            avg(l1.totalmean) AS point_avg_acc,
            avg(l1.totalnumberofsteps::numeric) AS point_avg_steps,
            avg(l1.dist_to_prev) AS point_avg_dist,
            count(l1.id) AS period_number_of_points,
            sum(l1.dist_to_prev) AS travelled_distance,
            avg(l2.to_time - l2.from_time) AS duration_of_tripleg,
                CASE
                    WHEN (l2.to_time - l2.from_time) <> 0 THEN 1000::double precision * sum(l1.dist_to_prev) / avg(l2.to_time - l2.from_time + 1)::double precision
                    ELSE avg(l1.speed_)
                END AS speed_overall_of_tripleg
           FROM apiv2.triplegs_gt l2,
            ( SELECT location_table.id,
                    location_table.user_id,
                    location_table.time_,
                    location_table.speed_,
                    location_table.totalmean,
                    location_table.totalnumberofsteps,
                    st_distance(st_makepoint(location_table.lon_, location_table.lat_)::geography, st_makepoint(lag(location_table.lon_) OVER (PARTITION BY location_table.user_id ORDER BY location_table.time_), lag(location_table.lat_) OVER (PARTITION BY location_table.user_id ORDER BY location_table.time_))::geography) AS dist_to_prev
                   FROM raw_data.location_table
                  WHERE location_table.accuracy_ <= 50::double precision) l1
          WHERE l2.type_of_tripleg = 1 AND l1.user_id = l2.user_id AND l1.time_ >= l2.from_time AND l1.time_ <= l2.to_time
          GROUP BY l2.user_id, l2.transportation_type, l2.from_time, l2.to_time
          ORDER BY l2.user_id, l2.transportation_type) foo
  GROUP BY foo.transportation_type
  WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS learning_processes.summary_of_mode_per_user AS 
 SELECT foo.user_id,
    foo.transportation_type,
    avg(foo.point_avg_speed) AS point_avg_speed,
    avg(foo.point_avg_acc) AS point_avg_acc,
    avg(foo.point_avg_steps) AS point_avg_steps,
    avg(foo.point_avg_dist) AS point_avg_dist,
    avg(foo.travelled_distance) AS travelled_distance,
    avg(foo.duration_of_tripleg) AS duration_of_tripleg,
    avg(foo.speed_overall_of_tripleg) AS speed_overall_of_tripleg,
    current_date as last_refreshed
   FROM ( SELECT l2.user_id,
            l2.transportation_type,
            avg(l1.speed_) AS point_avg_speed,
            avg(l1.totalmean) AS point_avg_acc,
            avg(l1.totalnumberofsteps) AS point_avg_steps,
            avg(l1.dist_to_prev) AS point_avg_dist,
            count(l1.id) AS period_number_of_points,
            sum(l1.dist_to_prev) AS travelled_distance,
            avg(l2.to_time - l2.from_time) AS duration_of_tripleg,
                CASE
                    WHEN (l2.to_time - l2.from_time) <> 0 THEN 1000::double precision * sum(l1.dist_to_prev) / avg(l2.to_time - l2.from_time + 1)::double precision
                    ELSE avg(l1.speed_)
                END AS speed_overall_of_tripleg 
           FROM apiv2.triplegs_gt l2,
            ( SELECT location_table.id,
                    location_table.user_id,
                    location_table.time_,
                    location_table.speed_,
                    location_table.totalmean,
                    location_table.totalnumberofsteps,
                    st_distance(st_makepoint(location_table.lon_, location_table.lat_)::geography, st_makepoint(lag(location_table.lon_) OVER (PARTITION BY location_table.user_id ORDER BY location_table.time_), lag(location_table.lat_) OVER (PARTITION BY location_table.user_id ORDER BY location_table.time_))::geography) AS dist_to_prev
                   FROM raw_data.location_table
                  WHERE location_table.accuracy_ <= 50::double precision) l1
          WHERE l2.type_of_tripleg = 1 AND l1.user_id = l2.user_id AND l1.time_ >= l2.from_time AND l1.time_ <= l2.to_time
          GROUP BY l2.user_id, l2.transportation_type, l2.from_time, l2.to_time
          ORDER BY l2.user_id, l2.transportation_type) foo
  GROUP BY foo.user_id, foo.transportation_type
  WITH DATA;

CREATE OR REPLACE FUNCTION learning_processes.refresh_materialized_views()
  RETURNS trigger AS
$BODY$
DECLARE 
last_refresh_date_of_view date;
annotation_date_of_trip date; 
BEGIN  
	
  annotation_date_of_trip := to_timestamp(NEW.to_time/1000)::date;
  last_refresh_date_of_view := last_refreshed from learning_processes.summary_of_mode_overall limit 1; 

  raise notice '%, %',annotation_date_of_trip , last_refresh_date_of_view;

  IF last_refresh_date_of_view IS NULL THEN 
	raise notice 'Refreshing materialized view for the first time';
	refresh materialized view learning_processes.summary_of_mode_overall;
	refresh materialized view learning_processes.summary_of_mode_per_user;
	ELSE 
		IF last_refresh_date_of_view < annotation_date_of_trip THEN 
			raise notice 'Refreshing materialized view';
			refresh materialized view learning_processes.summary_of_mode_overall;
			refresh materialized view learning_processes.summary_of_mode_per_user;
		ELSE RETURN NEW;
		END IF; 
	END IF; 
  RETURN NEW; 
END; 
$BODY$  
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_annotated_trip ON apiv2.trips_gt; 

CREATE TRIGGER tg_annotated_trip 
AFTER INSERT ON apiv2.trips_gt 
FOR EACH ROW WHEN (NEW.type_of_trip = 1)
EXECUTE PROCEDURE learning_processes.refresh_materialized_views(); 

CREATE OR REPLACE FUNCTION learning_processes.ap_get_destinations_close_by(
    latitude double precision,
    longitude double precision,
    user_id bigint,
    destination_poi_id bigint)
  RETURNS json AS
$BODY$ 
with point_geometry as 
	(select st_setsrid(st_makepoint($2, $1),4326) as orig_pt_geom),
pois_within_buffer as 
	(
	select  gid, lat_ as latitude, lon_ as longitude, 
	case when name_='' then type_ else name_ end as name, 
	type_, is_personal as added_by_user, st_distance(p1.geom, p2.orig_pt_geom) as dist from apiv2.pois as p1, point_geometry as p2 where 
	(p1.gid=$4) or (st_dwithin(p1.geom, p2.orig_pt_geom,500, true) 
	and (user_id= $3 or user_id is null))
	), 
counted_pois_within_buffer as 
	(
	select pois.gid, latitude, longitude,
	name, type_, added_by_user,
	count(*) from pois_within_buffer as pois
	left outer join apiv2.trips_gt as tgt
	on pois.gid = tgt.destination_poi_id 
	and tgt.user_id = $3
	group by pois.gid, latitude, longitude, name, type_, added_by_user
	), 
response as (select gid, latitude, longitude,
	name, type_, added_by_user,
	case when (gid = $4) then 100 else 
		case when added_by_user then 2* (least (count, 5) * 10.0)
		else least(count,5) * 10.0 
		end 
	end as accuracy from counted_pois_within_buffer) 
	
select array_to_json(array_agg(x)) from (select * from response) x  

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION learning_processes.ap_get_purposes(trip_id integer)
  RETURNS json AS
$BODY$
--explain 
WITH   
trip_candidate as (select * from apiv2.trips_inf
where trip_id = $1),
user_generated_trips as 
(
select  
EXTRACT (DOW FROM to_timestamp(to_time/1000)) as to_time_dow, 
EXTRACT (HOUR FROM to_timestamp(to_time/1000)) as to_time_hour,
purpose_id,
count(*) 
from apiv2.trips_gt 
group by -- from_time_dow, from_time_hour, 
to_time_dow, to_time_hour, purpose_id
), 
crowd_knowledge as 
(select t2.purpose_id, 
	case when @(EXTRACT (HOUR FROM to_timestamp(t1.to_time/1000)) - t2.to_time_hour) = 0 
		then count 
		else count / @(EXTRACT (HOUR FROM to_timestamp(t1.to_time/1000)) - t2.to_time_hour) end as prob 
		from user_generated_trips as t2, trip_candidate as t1
where EXTRACT (DOW FROM to_timestamp(t1.to_time/1000)) = t2.to_time_dow
and @(EXTRACT (HOUR FROM to_timestamp(t1.to_time/1000)) - t2.to_time_hour )<=2 
order by prob), 
user_history as 
(select t2.purpose_id, 2*count(*) as count from apiv2.trips_gt as t2, trip_candidate as t1
where t2.destination_poi_id = t1.destination_poi_id
and t2.user_id = $1
group by t2.purpose_id 
order by count),
purpose_inference as (select case when exists (select * from user_history) 
then (select array_to_json(array_agg(x order by accuracy desc)) from 
 
(select purpose_id as id, case when count > 20 then 100 else count*5 end as accuracy, (select name_ from apiv2.purpose_table pt where pt.id = foo.purpose_id) as name, (select name_sv from apiv2.purpose_table pt where pt.id = foo.purpose_id) as name_sv 
from(
select distinct on (purpose_id) * from user_history 
union all (select id, 0 from apiv2.purpose_table
 where not id = any (select purpose_id from user_history ))  
) as foo order by accuracy desc) x
)
else (select array_to_json(array_agg(x order by accuracy desc)) from 
 
(select distinct on (purpose_id) purpose_id as id, case when count > 20 then 100 else count*5 end as accuracy, 
	(select name_ from apiv2.purpose_table pt where pt.id = foo.purpose_id) as name, (select name_sv from apiv2.purpose_table pt where pt.id = foo.purpose_id) as name_sv 
from(
select purpose_id, prob as count from crowd_knowledge
union all (select id, 0 as count from apiv2.purpose_table 
 where not id = any (select purpose_id from crowd_knowledge) 
 )
 order by count desc  
) as foo) x 
) end) 

select array_to_json as purposes from purpose_inference
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
  
CREATE OR REPLACE FUNCTION learning_processes.ap_get_probable_modes_of_tripleg_json(triplegid bigint)
  RETURNS json AS
$BODY$
WITH 
considered_tripleg as (select * from apiv2.triplegs_inf where tripleg_id = $1),
inference_points_stat as (SELECT id, time_, speed_, totalmean, totalnumberofsteps, st_distance(st_makepoint(lon_, lat_)::geography, 
		st_makepoint(lag(lon_) over (partition by l1.user_id order by time_ ),
		lag(lat_) over (partition by l1.user_id order by time_ ))::geography) as dist_to_prev 
                 FROM raw_data.location_table as l1, considered_tripleg as l2 where l1.user_id = l2.user_id and l1.time_ between l2.from_time and l2.to_time and accuracy_<=50), 
last_point_of_considered_tripleg as (select lat_, lon_ from raw_data.location_table as l1, considered_tripleg as l2 where l1.id=l2.to_point_id),
transportation_mode_probability as (select array_to_json(array_agg((SELECT x FROM (SELECT id as id, 0 AS certainty, name_ as name, name_sv as name_sv) x) )) as mode FROM apiv2.travel_mode_table),
points as (SELECT array_to_json(array_agg( (SELECT x FROM (
select x from (select id, lat,lon, time) x) as final_selection) ) ) as points from 
(select * from (
SELECT id as id, lat_ AS lat, lon_ AS lon, time_ as time 
                 FROM raw_data.location_table as l1, considered_tripleg as l2 where l1.user_id = l2.user_id and l1.time_ between l2.from_time and l2.to_time and accuracy_<=50) as gps_points)
                 as total_selection),

all_users_point_based_similarity as (
select transportation_type, case when transportation_type = 15 then 0 else avg(speed_similarity*0.25 + acc_similarity*0.25 + steps_similarity*0.25 + dist_similarity*0.25) end as total_similarity
from (
select 
po.id, inf.transportation_type,
least(po.speed_+0.01,inf.point_avg_speed+0.01)/greatest(po.speed_+0.01,inf.point_avg_speed+0.01) as speed_similarity,
least(po.totalmean+0.01,inf.point_avg_acc+0.01)/greatest(po.totalmean+0.01,inf.point_avg_acc+0.01) as acc_similarity,
case when po.totalnumberofsteps+0.01=0 and inf.point_avg_steps+0.01=0 then 1 else least(po.totalnumberofsteps+0.01,inf.point_avg_steps+0.01)/greatest(po.totalnumberofsteps+0.01,inf.point_avg_steps+0.01) end as steps_similarity,
case when po.dist_to_prev+0.01 is null then 0 else least(po.dist_to_prev+0.01,inf.point_avg_dist+0.01)/greatest(po.dist_to_prev+0.01,inf.point_avg_dist+0.01) end as dist_similarity 
from inference_points_stat as po, learning_processes.summary_of_mode_overall as inf) as foo 
group by transportation_type 
order by total_similarity desc ),

all_users_period_based_similarity as (
select transportation_type, dist_similarity*0.33 + duration_similarity*0.33 + speed_similarity*0.33 as total_similarity from 
(select transportation_type,
least(sum(dist_to_prev), inf.travelled_distance+0.01) / greatest(sum(dist_to_prev), inf.travelled_distance+0.01) as dist_similarity,
least ((max(time_)-min(time_)), duration_of_tripleg+0.01) / greatest((max(time_)-min(time_)), duration_of_tripleg+0.01) as duration_similarity,
least ((1000*sum(dist_to_prev) / (max(time_)-min(time_))) , inf.speed_overall_of_tripleg+0.01) /greatest((1000*sum(dist_to_prev) / (max(time_)-min(time_))) , inf.speed_overall_of_tripleg+0.01) as speed_similarity
from inference_points_stat as po, learning_processes.summary_of_mode_overall as inf
group by transportation_type, inf.travelled_distance+0.01, duration_of_tripleg+0.01, speed_overall_of_tripleg
order by transportation_type) as foo 
order by total_similarity desc), 

user_specific_point_based_similarity as (
select transportation_type, case when transportation_type = 15 then 0 else avg(speed_similarity*0.25 + acc_similarity*0.25 + steps_similarity*0.25 + dist_similarity*0.25) end as total_similarity
from (
select 
po.id, inf.transportation_type,
least(po.speed_+0.01,inf.point_avg_speed+0.01)/greatest(po.speed_+0.01,inf.point_avg_speed+0.01) as speed_similarity,
least(po.totalmean+0.01,inf.point_avg_acc+0.01)/greatest(po.totalmean+0.01,inf.point_avg_acc+0.01) as acc_similarity,
case when po.totalnumberofsteps+0.01=0 and inf.point_avg_steps+0.01=0 then 1 else least(po.totalnumberofsteps+0.01,inf.point_avg_steps+0.01)/greatest(po.totalnumberofsteps+0.01,inf.point_avg_steps+0.01) end as steps_similarity,
case when po.dist_to_prev+0.01 is null then 0 else least(po.dist_to_prev+0.01,inf.point_avg_dist+0.01)/greatest(po.dist_to_prev+0.01,inf.point_avg_dist+0.01) end as dist_similarity 
from inference_points_stat as po, (select * from learning_processes.summary_of_mode_per_user where user_id = (select user_id from considered_tripleg)) as inf) as foo 
group by transportation_type 
order by total_similarity desc ),

user_specific_period_based_similarity as (
select transportation_type, dist_similarity*0.33 + duration_similarity*0.33 + speed_similarity*0.33 as total_similarity from 
(select transportation_type,
least(sum(dist_to_prev), inf.travelled_distance+0.01) / greatest(sum(dist_to_prev), inf.travelled_distance+0.01) as dist_similarity,
least ((max(time_)-min(time_)), duration_of_tripleg+0.01) / greatest((max(time_)-min(time_)), duration_of_tripleg+0.01) as duration_similarity,
least ((1000*sum(dist_to_prev) / (max(time_)-min(time_))) , inf.speed_overall_of_tripleg+0.01) /greatest((1000*sum(dist_to_prev) / (max(time_)-min(time_))) , inf.speed_overall_of_tripleg+0.01) as speed_similarity
from inference_points_stat as po, (select * from learning_processes.summary_of_mode_per_user where user_id = (select user_id from considered_tripleg)) as inf 
group by transportation_type, inf.travelled_distance+0.01, duration_of_tripleg+0.01, speed_overall_of_tripleg
order by transportation_type) as foo 
order by total_similarity desc ), 
predicted_modes as (
select t1.id, (case when t2.total_similarity is null then 0 else t2.total_similarity end * 0.17 + case when t3.total_similarity is null then 0 else t3.total_similarity end * 0.17 
+ case when t4.total_similarity is null then 0 else t4.total_similarity end * 0.33
+ case when t5.total_similarity is null then 0 else t5.total_similarity end * 0.33) *100 as mode_probability,
t1.name_, t1.name_sv
from apiv2.travel_mode_table as t1
left outer join all_users_point_based_similarity as t2 on t1.id = t2.transportation_type 
left outer join all_users_period_based_similarity as t3 on t1.id = t3.transportation_type 
left outer join user_specific_point_based_similarity as t4 on t1.id = t4.transportation_type 
left outer join user_specific_period_based_similarity as t5 on t1.id = t5.transportation_type 
order by mode_probability desc 
) 

select array_to_json(array_agg((SELECT x FROM (SELECT mode_probability AS accuracy, id as id, name_ as name, name_sv as name_sv) x) )) as mode FROM predicted_modes
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

-- MAPPING THE REGULAR FUNCTIONS TO THE NEW ONES 

DROP FUNCTION IF EXISTS apiv2.ap_get_purposes(integer);

CREATE OR REPLACE FUNCTION apiv2.ap_get_purposes(trip_id integer)
  RETURNS json AS
$BODY$ 
SELECT ap_get_purposes FROM learning_processes.ap_get_purposes($1);
$BODY$
LANGUAGE SQL; 

DROP FUNCTION IF EXISTS apiv2.ap_get_destinations_close_by(double precision, double precision, bigint, bigint);

CREATE OR REPLACE FUNCTION apiv2.ap_get_destinations_close_by(
    latitude double precision,
    longitude double precision,
    user_id bigint,
    destination_poi_id bigint)
  RETURNS json AS
$BODY$ 
SELECT ap_get_destinations_close_by from learning_processes.ap_get_destinations_close_by($1,$2,$3,$4)
$BODY$
LANGUAGE SQL; 

DROP FUNCTION IF EXISTS apiv2.ap_get_probable_modes_of_tripleg_json(integer);

CREATE OR REPLACE FUNCTION apiv2.ap_get_probable_modes_of_tripleg_json(triplegid integer)
  RETURNS json AS
$BODY$
SELECT ap_get_probable_modes_of_tripleg_json FROM learning_processes.ap_get_probable_modes_of_tripleg_json($1)
$BODY$
LANGUAGE SQL;