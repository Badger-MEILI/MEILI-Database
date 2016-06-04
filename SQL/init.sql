/*
MEILI Database - provides storage and API functionality for the MEILI Travel Diary web app and other apps part of the MEILI family. 

This DATABASE is made available under the Open Data Commons Attribution License (ODC-By) v1.0. It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Copyright (C) 2014-2016 Adrian C. Prelipcean - http://adrianprelipcean.github.io/
Copyright (C) 2016 adIT AI - https://github.com/adIT-AI

You should have received a copy of the Open Data Commons Attribution License (ODC-By) v1.0 along with this program.  If not, <see http://opendatacommons.org/wp-content/uploads/2010/01/odc_by_1.0_public_text.txt>
*/


/**
===============================EXTENSIONS==================================
*/


CREATE EXTENSION IF NOT EXISTS plpgsql; 
CREATE EXTENSION IF NOT EXISTS postgis; --version 2.1.7 


/**
===============================TABLE DEFINITIONS==================================
*/

CREATE TABLE contact_form
(
  contact_name text,
  email_address text,
  phone_number text,
  message text,
  sent boolean DEFAULT false
);


CREATE TABLE location_table
(
  id serial NOT NULL,
  upload boolean DEFAULT false,
  accuracy_ double precision,
  altitude_ double precision,
  bearing_ double precision,
  lat_ double precision,
  lon_ double precision,
  time_ bigint,
  speed_ double precision,
  satellites_ integer,
  user_id integer,
  size integer,
  totalismoving boolean,
  totalmax real,
  totalmean real,
  totalmin real,
  totalnumberofpeaks integer,
  totalnumberofsteps integer,
  totalstddev real,
  xismoving boolean,
  xmaximum real,
  xmean real,
  xminimum real,
  xnumberofpeaks integer,
  xstddev real,
  yismoving boolean,
  ymax real,
  ymean real,
  ymin real,
  ynumberofpeaks integer,
  ystddev real,
  zismoving boolean,
  zmax real,
  zmean real,
  zmin real,
  znumberofpeaks integer,
  zstddev real,
  provider character varying(15)
);


CREATE TABLE locations_added_by_user
(
  latitude_ double precision,
  longitude_ double precision,
  userid bigint,
  time_ bigint,
  from_id bigint,
  to_id bigint,
  id bigint DEFAULT nextval('location_table_id_seq'::regclass)
);



CREATE TABLE log_table
(
  userid integer,
  log_date text NOT NULL,
  log_message text
);


CREATE TABLE log_table_web
(
  userid integer,
  log_date bigint NOT NULL,
  log_message text,
  back_front text,
  extra_stack text
);



CREATE TABLE poi_personal
(
  gid serial NOT NULL,
  type_ text,
  name_ text,
  lat_ double precision,
  lon_ double precision,
  declaring_user_id integer,
  geom geometry(Point,3006)
);



CREATE TABLE poi_public
(
  osm_id bigint,
  type_ text,
  name_ text,
  lat_ double precision,
  lon_ double precision,
  type_sv text,
  geom geometry(Point,3006)
);



CREATE TABLE poi_transportation
(
  osm_id bigint,
  type_ text,
  name_ text,
  lat_ double precision,
  lon_ double precision,
  declared_by_user boolean DEFAULT false,
  transportation_lines text,
  transportation_types text,
  declaring_user_id integer,
  generated_id serial NOT NULL,
  type_sv text,
  geom geometry(Point,3006)
);



CREATE TABLE purpose_table
(
  id smallint,
  name_ text,
  name_sv text
);



CREATE TABLE transportation_modes
(
  id smallint,
  name_ text,
  name_sv text
);

CREATE TABLE triplegs_gt
(
  tripleg_id text,
  trip_id text,
  user_id bigint,
  from_point_id text,
  to_point_id text,
  from_time bigint,
  to_time bigint,
  type_of_tripleg smallint,
  transportation_type integer,
  transition_poi_id bigint,
  length_of_tripleg double precision,
  duration_of_tripleg double precision,
  gid_tripleg serial NOT NULL,
  trip_gid bigint
);



CREATE TABLE triplegs_inf
(
  user_id bigint,
  from_point_id bigint,
  to_point_id bigint,
  from_time bigint,
  to_time bigint,
  type_of_tripleg smallint,
  transportation_type integer,
  transition_poi_id bigint,
  length_of_tripleg double precision,
  duration_of_tripleg double precision,
  tripleg_id serial NOT NULL,
  trip_id bigint
); 



CREATE TABLE trips_gt
(
  trip_id text,
  user_id bigint,
  from_point_id text,
  to_point_id text,
  from_time bigint,
  to_time bigint,
  type_of_trip smallint,
  purpose_id integer,
  destination_poi_id bigint,
  length_of_trip double precision,
  duration_of_trip double precision,
  number_of_triplegs integer,
  gid serial NOT NULL
);



CREATE TABLE trips_inf
(
  user_id bigint,
  from_point_id bigint,
  to_point_id bigint,
  from_time bigint,
  to_time bigint,
  type_of_trip smallint,
  purpose_id integer,
  destination_poi_id bigint,
  length_of_trip double precision,
  duration_of_trip double precision,
  number_of_triplegs integer,
  trip_id serial NOT NULL
);


CREATE TABLE user_table
(
  id serial NOT NULL,
  username text NOT NULL,
  password text,
  phone_model text,
  phone_os text,
  CONSTRAINT user_table_pkey PRIMARY KEY (id)
);

/**
===============================FUNCTION DEFINITIONS===============================
*/


/*DELETE OPERATIONS*/

CREATE OR REPLACE FUNCTION ap_delete_artificial_user_point(id bigint)
  RETURNS void AS
$BODY$
DELETE FROM locations_added_by_user where id = $1
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;





CREATE OR REPLACE FUNCTION ap_delete_trip_gt(trip_id text)
  RETURNS void AS
$BODY$
  delete from trips_gt where trip_id = $1
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_delete_tripleg_gt(tripleg_id text)
  RETURNS void AS
$BODY$
  delete from triplegs_gt
  where tripleg_id = $1
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100;


/*BUFFER EXTRACTION OPERATIONS*/

CREATE OR REPLACE FUNCTION ap_get_destinations_close_by(
    latitude double precision,
    longitude double precision,
    user_id bigint)
  RETURNS json AS
$BODY$

with point_geometry as (select st_transform(st_setsrid(st_makepoint($2, $1),4326),3006) as orig_pt_geom),
personal_pois_within_buffer as (select gid as db_id, gid as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type, 1 as added_by_user, st_distance(p1.geom, p2.orig_pt_geom) as dist from poi_personal as p1, point_geometry as p2 where st_dwithin(p1.geom, p2.orig_pt_geom,500) and declaring_user_id= $3),
public_pois_within_buffer as (select osm_id as db_id, osm_id as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type,  -1 as added_by_user, st_distance(p1.geom, p2.orig_pt_geom) as dist from poi_public as p1, point_geometry as p2 where st_dwithin(p1.geom, p2.orig_pt_geom, 500)),
 
all_pois_within_buffer as (select distinct on (db_id, osm_id) db_id, osm_id, latitude, longitude, dist, case when name='' then type else name end as name, type, added_by_user from (select * from personal_pois_within_buffer union all select * from public_pois_within_buffer order by dist) as foo),
response as (select db_id, osm_id, latitude, longitude, case when name='' then type else name end as name, type, added_by_user, 0 as accuracy from all_pois_within_buffer) 
select array_to_json(array_agg(x)) from (select * from response) x 

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION ap_get_pois_within_buffer(
    lat_ double precision,
    lon_ double precision,
    buffer_in_meters double precision)
  RETURNS json AS
$BODY$
with point_geometry as (select st_makepoint($2, $1)::geography as orig_pt_geography),
personal_pois_within_buffer as (select gid as db_id, gid as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type, 0 as accuracy, 1 as added_by_user, st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography) as dist from poi_personal as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3),
public_pois_within_buffer as (select osm_id as db_id, osm_id as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type, 0 as accuracy, -1 as added_by_user, st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography) as dist from poi_public as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3)

select array_to_json(array_agg(x)) from (select distinct on (db_id, osm_id) db_id, osm_id, latitude, longitude, case when name='' then type else name end as name, type, accuracy, added_by_user from (select * from personal_pois_within_buffer union all select * from public_pois_within_buffer order by dist) as foo) x 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION ap_get_pois_within_buffer(
    lat_ double precision,
    lon_ double precision,
    buffer_in_meters double precision,
    osm_id bigint)
  RETURNS json AS
$BODY$
with point_geometry as (select st_makepoint($2, $1)::geography as orig_pt_geography),
personal_pois_within_buffer as (select gid as db_id, gid as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type, case when (gid=$4) then 100 else 0 end as accuracy, 1 as added_by_user, st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography) as dist from poi_personal as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3),
public_pois_within_buffer as (select osm_id as db_id, osm_id as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type, case when (osm_id=$4) then 100 else 0 end as accuracy, -1 as added_by_user, st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography) as dist from poi_public as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3)

select array_to_json(array_agg(x)) from (select distinct on (db_id, osm_id) db_id, osm_id, latitude, longitude, case when name='' then type else name end as name, type, accuracy, added_by_user from (select * from personal_pois_within_buffer union all select * from public_pois_within_buffer order by dist) as foo) x 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION ap_get_pois_within_buffer_gt(
    lat_ double precision,
    lon_ double precision,
    buffer_in_meters double precision,
    osm_id bigint)
  RETURNS json AS
$BODY$
with point_geometry as (select st_makepoint($2, $1)::geography as orig_pt_geography),
personal_pois_within_buffer as (select gid as db_id, gid as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type, case when (gid=$4) then 100 else 0 end as accuracy, 1 as added_by_user, st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography) as dist from poi_personal as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3),
public_pois_within_buffer as (select osm_id as db_id, osm_id as osm_id, lat_ as latitude, lon_ as longitude, name_ as name, type_ as type, case when (osm_id=$4) then 100 else 0 end as accuracy, -1 as added_by_user, st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography) as dist from poi_public as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3)

select array_to_json(array_agg(x)) from (select db_id, osm_id, latitude, longitude, case when name='' then type else name end as name, type, accuracy, added_by_user from (select * from personal_pois_within_buffer union all select * from public_pois_within_buffer order by dist) as foo) x 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION ap_get_transit_pois_within_buffer(
    lat_ double precision,
    lon_ double precision,
    buffer_in_meters double precision)
  RETURNS json AS
$BODY$
with point_geometry as (select st_transform(st_setsrid(st_makepoint($2, $1),4326),3006) as orig_pt_geom),
personal_transition_within_buffer as (SELECT osm_id as osm_id, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, 1 as added_by_user from poi_transportation as p1, point_geometry as p2 where st_dwithin(p2.orig_pt_geom,p1.geom, $3) and declared_by_user = true),
public_transition_within_buffer as (SELECT osm_id as osm_id, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, -1 as added_by_user from poi_transportation as p1, point_geometry as p2 where st_dwithin(p2.orig_pt_geom,p1.geom, $3) and declared_by_user = false)

select array_to_json(array_agg(x)) from (select * from personal_transition_within_buffer union all select * from public_transition_within_buffer) x 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_get_transit_pois_within_buffer(
    lat_ double precision,
    lon_ double precision,
    buffer_in_meters double precision,
    osm_id bigint)
  RETURNS json AS
$BODY$

with point_geometry as (select st_transform(st_setsrid(st_makepoint($2, $1),4326),3006) as orig_pt_geom),
all_points_within_buffer as (SELECT generated_id as osm_id, false as chosen_by_user, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, case when declared_by_user then 1 else -1 end as added_by_user from poi_transportation as p1, point_geometry as p2 
where st_dwithin(p2.orig_pt_geom,p1.geom, $3)
and generated_id<>$4
),
chosen_point_by_user as (SELECT generated_id as osm_id, true as chosen_by_user, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, case when declared_by_user then 1 else -1 end as added_by_user from poi_transportation where generated_id = $4)

select array_to_json(array_agg(x)) from (select * from chosen_point_by_user union all select * from all_points_within_buffer) x 
 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION ap_get_transit_pois_within_buffer_gt(
    lat_ double precision,
    lon_ double precision,
    buffer_in_meters double precision,
    osm_id bigint)
  RETURNS json AS
$BODY$
with point_geometry as (select st_makepoint($2, $1)::geography as orig_pt_geography),
personal_transition_within_buffer as (SELECT osm_id as osm_id, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, 1 as added_by_user from poi_transportation as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3 and declared_by_user = true),
public_transition_within_buffer as (SELECT osm_id as osm_id, type_ AS type, name_ as name, lat_ as lat, lon_ as lon, -1 as added_by_user from poi_transportation as p1, point_geometry as p2 where st_distance(st_makepoint(lon_, lat_)::geography, p2.orig_pt_geography)<=$3 and declared_by_user = false)

select array_to_json(array_agg(x)) from (select *, case when osm_id = $4 then true else false end as chosen_by_user from personal_transition_within_buffer union all select *,case when osm_id = $3 then true else false end as chosen_by_user from public_transition_within_buffer) x 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;



/*INFO EXTRACTION OPERATIONS*/

CREATE OR REPLACE FUNCTION ap_get_modes_json()
  RETURNS json AS
$BODY$
	select array_to_json(array_agg((SELECT x FROM (SELECT id as id, 0 AS certainty, name_ as name, name_sv as name_sv) x) )) as mode FROM transportation_modes
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION ap_get_purposes()
  RETURNS json AS
$BODY$
--explain 
select array_to_json(array_agg((SELECT x FROM (SELECT 0 as accuracy, id, name_ as name, name_sv) x) )) as mode FROM purpose_table
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_get_tripleg_gt_json(triplegid text)
  RETURNS json AS
$BODY$
--EXPLAIN
WITH 
considered_tripleg as (select * from triplegs_gt where tripleg_id = $1 order by transition_poi_id limit 1),
last_point_pre_process as ( select to_point_id::integer as id from considered_tripleg),
last_point_of_considered_tripleg as (select lat_, lon_ from (select id, lat_, lon_ from location_table where id = (select id from last_point_pre_process) union all 
		(select id, latitude_ as lat_, longitude_ as lon_ from locations_added_by_user where id = (select id from last_point_pre_process))) as foo ),
transportation_mode_probability as (select array_to_json(array_agg((SELECT x FROM (SELECT t.id as id, 100 AS certainty, t.name_ as name, t.name_sv as name_sv where c.transportation_type = t.id union all SELECT t.id as id, 0 AS certainty, t.name_ as name, t.name_sv as name_sv where c.transportation_type <> t.id ) x) ) ) as mode FROM considered_tripleg as c, transportation_modes as t),
points as (SELECT array_to_json(array_agg( (SELECT x FROM (
select x from (select id, lat,lon, time) x)  as final_selection) ) ) as points from 
(select * from (
SELECT id as id, lat_ AS lat, lon_ AS lon, time_ as time 
                 FROM location_table as l1, considered_tripleg as l2 where l1.user_id = l2.user_id and l1.time_>= l2.from_time and l1.time_<=l2.to_time and accuracy_<=50) as gps_points
                 union all 
(SELECT id as id, latitude_ AS lat, longitude_ AS lon,  time_ as time FROM locations_added_by_user as l1, considered_tripleg as l2 where l1.time_>=l2.from_time and l1.time_<=l2.to_time and l2.user_id = l1.userid)
order by time) as total_selection),
places as (SELECT ap_get_transit_pois_within_buffer(l3.lat_,l3.lon_,500, l1.transition_poi_id) as places FROM last_point_of_considered_tripleg as l3, considered_tripleg as l1)

select row_to_json(r) from (
select tl.tripleg_id as triplegid,
tl.type_of_tripleg,
po.points, 
mo.mode,
1 as defined_by_user,
case when pl.places is null then '{}'::json else pl.places end as places
from points as po, places as pl, transportation_mode_probability as mo, considered_tripleg as tl
) r 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_get_tripleg_inf_json(triplegid integer)
  RETURNS json AS
$BODY$
WITH 
considered_tripleg as (select * from triplegs_inf where tripleg_id = $1),
last_point_of_considered_tripleg as (select lat_, lon_ from location_table as l1, considered_tripleg as l2 where l1.id=l2.to_point_id),
transportation_mode_probability as (select * from ap_get_modes_json() as mode),
points as (SELECT array_to_json(array_agg( (SELECT x FROM (
select x from (select id, lat,lon, time) x) as final_selection) ) ) as points from 
(select * from (
SELECT id as id, lat_ AS lat, lon_ AS lon, time_ as time 
                 FROM location_table as l1, considered_tripleg as l2 where l1.user_id = l2.user_id and l1.id>= l2.from_point_id and l1.id<=l2.to_point_id and accuracy_<=50) as gps_points
                /* union all 
(SELECT id::text as id, latitude_ AS lat, longitude_ AS lon, to_timestamp(time_/1000)::timestamp without time zone as time FROM locations_added_by_user as l1, considered_tripleg as l2 where l1.tripleg_id= l2.tripleg_id)
order by time*/) as total_selection),
places as (SELECT ap_get_transit_pois_within_buffer(l3.lat_,l3.lon_,500) as places FROM last_point_of_considered_tripleg as l3)

select row_to_json(r) from (
select tl.tripleg_id as triplegid,
tl.type_of_tripleg,
po.points, 
mo.mode,
case when pl.places is null then '{}'::json else pl.places end as places
from points as po, places as pl, transportation_mode_probability as mo, considered_tripleg as tl
) r 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

 
CREATE OR REPLACE FUNCTION ap_get_trip_gt_json(tripid text)
  RETURNS json AS
$BODY$
--explain 
WITH 
considered_trip as (select *,-1 as foo from trips_gt where trip_id = $1 order by destination_poi_id limit 1),
user_id as (select user_id from considered_trip),
last_annotated_ground_truth_trip as (select t.* from trips_gt as t, user_id as u where t.user_id = u.user_id order by to_time desc limit 1),
ground_truth_trips_that_need_annotation as (select t.* from trips_gt as t, user_id as u where  t.user_id = u.user_id and destination_poi_id=-1),
ground_truth_trips_that_do_not_need_annotation as (select trip_id, 'verified'::text as type_of_selection, from_time, to_time, type_of_trip from trips_gt as t, user_id as u where destination_poi_id>=0 and u.user_id = t.user_id order by from_time, to_time),
last_annotated_time as (select case when exists(select to_time from last_annotated_ground_truth_trip) then (select to_time from last_annotated_ground_truth_trip)
else 0 end as to_time),
infered_trips_that_needs_annotation as (select t1.* from trips_inf as t1, last_annotated_time as t2, user_id as u where t1.from_time>=t2.to_time and t1.user_id = u.user_id), 
all_trips_that_need_annotation as (select trip_id::text, 'inferred'::text as type_of_selection, from_time, to_time, type_of_trip from infered_trips_that_needs_annotation union all
select trip_id, 'ground_truth'::text as type_of_selection, from_time, to_time, type_of_trip from ground_truth_trips_that_need_annotation
order by from_time, to_time),
all_trips as (select * from ground_truth_trips_that_do_not_need_annotation union all
select * from all_trips_that_need_annotation),
last_point_pre_process as (select l2.to_point_id::int as id from considered_trip as l2),
last_point_of_considered_trip as (select lat_, lon_ from (select id, lat_, lon_ from location_table where id = (select id from last_point_pre_process) union all select id, latitude_ as lat_, longitude_ as lon_ from locations_added_by_user where id = (select id from last_point_pre_process)) as l1),
prev_considered_trip as (select t1.*,-1 as foo from trips_gt as t1, considered_trip as t2 where t2.from_time >= t1.to_time and t1.type_of_trip>0 and t1.user_id = t2.user_id and t1.trip_id<>t2.trip_id order by t1.to_time desc limit 1),
next_considered_trip as (select t1.*,-1 as foo  from all_trips as t1, considered_trip as t2 where t2.to_time <= t1.from_time and t1.type_of_trip>0 order by t1.to_time asc limit 1),
prev_trip_info as (select -1 as foo ,to_time as prev_trip_stop, purpose_id as prev_trip_purpose, destination_poi_id  as prev_trip_place,
(select name_ from (select gid, name_ from poi_personal union all select osm_id,name_ from poi_public) as foo where gid= destination_poi_id limit 1) as prev_trip_name from prev_considered_trip),
next_trip_info as (select -1 as foo , from_time as next_trip_start from next_considered_trip),
purposes as (select -1 as foo, array_to_json(array_agg(r)) as purposes from (select p.id as id, 100 as accuracy, p.name_ as name, p.name_sv as name_sv from considered_trip as c, purpose_table as p where p.id = purpose_id
union all select p.id as id, 0 as accuracy, p.name_ as name, p.name_sv as name_sv from considered_trip as c, purpose_table as p where p.id <> purpose_id) r),
destination_places as (select -1 as foo , ap_get_pois_within_buffer(lat_, lon_, 500, (select destination_poi_id from considered_trip)) as destination_places from last_point_of_considered_trip),
triplegs as (select -1 as foo , array_to_json(array_agg(ap_get_tripleg_gt_json(t1.tripleg_id) order by t1.from_time, t1.to_time)) as triplegs from (select distinct on (tripleg_id) * from triplegs_gt) as t1, considered_trip as t2 
where t1.trip_id = t2.trip_id) 
select row_to_json(r) from 
(
select ct.trip_id as tripid, ct.type_of_trip as type_of_trip, pt.prev_trip_stop as prev_trip_stop, 
pt.prev_trip_purpose as prev_trip_purpose, pt.prev_trip_place as prev_trip_place, 
pt.prev_trip_name as prev_trip_place_name, 
nt.next_trip_start as next_trip_start, 
case when dest.destination_places is null then '{}' else dest.destination_places end as destination_places,
po.purposes as purposes, 
tl.triplegs as triplegs,
'1' as defined_by_user
from considered_trip as ct left join prev_trip_info as pt on ct.foo = pt.foo 
left join next_trip_info as nt on nt.foo = ct.foo 
left join purposes as po on po.foo =ct.foo 
left join destination_places as dest on dest.foo =ct.foo 
left join triplegs as tl on tl.foo = ct.foo 
) r 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION ap_get_trip_inf_json(tripid integer)
  RETURNS json AS
$BODY$
with
considered_trip as (select *,'foo' as foo from trips_inf where trip_id = $1),
user_id as (select user_id from considered_trip),
last_annotated_ground_truth_trip as (select t.* from trips_gt as t, user_id as u where t.user_id = u.user_id order by to_time desc limit 1),
ground_truth_trips_that_need_annotation as (select t.* from trips_gt as t, user_id as u where  t.user_id = u.user_id and destination_poi_id=-1),
ground_truth_trips_that_do_not_need_annotation as (select trip_id, 'verified'::text as type_of_selection, from_time, to_time, type_of_trip, purpose_id, destination_poi_id, t.user_id from trips_gt as t, user_id as u where destination_poi_id>=0 and u.user_id = t.user_id order by from_time, to_time),
last_annotated_time as (select case when exists(select to_time from last_annotated_ground_truth_trip) then (select to_time from last_annotated_ground_truth_trip)
else 0 end as to_time),
infered_trips_that_needs_annotation as (select t1.* from trips_inf as t1, last_annotated_time as t2, user_id as u where t1.from_time>=t2.to_time and t1.user_id = u.user_id), 
all_trips_that_need_annotation as (select trip_id::text, 'inferred'::text as type_of_selection, from_time, to_time, type_of_trip, purpose_id, destination_poi_id, user_id from infered_trips_that_needs_annotation union all
select trip_id, 'ground_truth'::text as type_of_selection, from_time, to_time, type_of_trip, purpose_id, destination_poi_id, user_id from ground_truth_trips_that_need_annotation
order by from_time, to_time),
all_trips as (select * from ground_truth_trips_that_do_not_need_annotation union all
select * from all_trips_that_need_annotation),

last_point_of_considered_trip as (select lat_, lon_ from location_table as l1, considered_trip as l2 where l2.to_point_id = l1.id),
prev_considered_trip as (select t1.*,'foo' as foo from all_trips as t1, considered_trip as t2 where t2.from_time > t1.to_time and t1.type_of_trip>0 and t1.user_id = t2.user_id
order by t1.to_time desc limit 1),
next_considered_trip as (select t1.*,'foo' as foo  from all_trips as t1, considered_trip as t2 where t2.to_time < t1.from_time and t1.type_of_trip>0 and t1.user_id = t2.user_id
order by t1.to_time asc limit 1),
prev_trip_info as (select 'foo' as foo ,to_time as prev_trip_stop, purpose_id as prev_trip_purpose, destination_poi_id  as prev_trip_place,
(select name_ from (select gid, name_ from (select gid, name_ from poi_personal where gid= destination_poi_id) a union all (select osm_id,name_ from poi_public where osm_id= destination_poi_id) limit 1) as foo) as prev_trip_name from prev_considered_trip),
next_trip_info as (select 'foo' as foo , from_time as next_trip_start from next_considered_trip),
destination_places as (select 'foo' as foo , ap_get_destinations_close_by(lat_, lon_, (select user_id from user_id)) as destination_places from last_point_of_considered_trip),
purposes as (select 'foo' as foo, ap_get_purposes() as purposes),
triplegs as (select 'foo' as foo , array_to_json(array_agg(ap_get_tripleg_inf_json(t1.tripleg_id) order by t1.from_time, t1.to_time)) as triplegs from triplegs_inf as t1, considered_trip  as t2 
where t1.trip_id = t2.trip_id and t1.user_id = t2.user_id) 

select row_to_json(r) from 
(
select ct.trip_id as tripid, ct.type_of_trip as type_of_trip, pt.prev_trip_stop as prev_trip_stop, 
pt.prev_trip_purpose as prev_trip_purpose, pt.prev_trip_place as prev_trip_place, 
pt.prev_trip_name as prev_trip_place_name, 
nt.next_trip_start as next_trip_start, 
case when dest.destination_places is null then '{}' else dest.destination_places end as destination_places,
po.purposes as purposes, 
tl.triplegs as triplegs
from considered_trip as ct left join prev_trip_info as pt on ct.foo::Text = pt.foo::TEXT
left join next_trip_info as nt on nt.foo::text = ct.foo::text
left join purposes as po on po.foo::text=ct.foo::text
left join destination_places as dest on dest.foo::text=ct.foo::text
left join triplegs as tl on tl.foo::text = ct.foo::text
) r 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


/*STREAM OPERATIONS*/

CREATE OR REPLACE FUNCTION ap_get_stream_for_stop_detection(userid integer)
  RETURNS json AS
$BODY$
with last_point_in_trip as (select to_point_id from trips_inf 
where user_id = $1 
order by to_time desc limit 1),
last_point_to_check as (select case when exists(select * from last_point_in_trip) is true then (select to_point_id from last_point_in_trip)
else 0 end as id)
select array_to_json(array_agg(result)) from 
(select *, l1.id as id_ from location_table as l1, last_point_to_check as l2 
where l1.id >= l2.id and l1.user_id = $1
order by l1.id) as result
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION ap_get_stream_for_tripleg_detection(userid integer)
  RETURNS json AS
$BODY$
with last_point_in_tripleg as (select to_point_id from triplegs_inf 
where user_id = $1 
order by to_time desc limit 1),
last_point_to_check as (select case when exists(select * from last_point_in_tripleg) is true then (select to_point_id from last_point_in_tripleg)
else 0 end as id)
select array_to_json(array_agg(result)) from 
(select * from (select (select trip_id from trips_inf where from_point_id<=l1.id and to_point_id>=l1.id and user_id = $1 limit 1) as trip_id, l1.*, l1.id as id_ from location_table as l1, last_point_to_check as l2 
where l1.id > l2.id and l1.user_id = $1
order by l1.id) as foo where trip_id is not null ) as result
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
 

/*STATS OPERATIONS*/

CREATE OR REPLACE FUNCTION ap_get_user_stats(user_id bigint)
  RETURNS json AS
$BODY$
with pre_meta_centralized as 
(
select year_, month_, day_, dow_, hour_, steps, lat_,lon_,accuracy_, type_of_transport, tripleg_id, dist,
case when type_of_transport=12 or type_of_transport=9 or type_of_transport= 11 then dist*0.034 else 
	case when type_of_transport = 8 then dist*0.04 else
		case when type_of_transport=3 then dist*0.07 else
			case when type_of_transport = 13 then dist*0.125 else
				case when type_of_transport = 4 or type_of_transport = 5 or type_of_transport = 7 or type_of_transport = 6 then dist*0.180 else
					0 
				end
			end
		end
	end
end as co2_emission, 
time_ 
from (
select EXTRACT (year FROM to_timestamp(time_/1000)::timestamp with time zone at time zone 'Europe/Stockholm') as year_, 
EXTRACT (MONTH FROM to_timestamp(time_/1000)::timestamp with time zone at time zone 'Europe/Stockholm') as month_, 
EXTRACT (DAY FROM to_timestamp(time_/1000)::timestamp with time zone at time zone 'Europe/Stockholm') as day_, 
EXTRACT (DOW FROM to_timestamp(time_/1000)::timestamp with time zone at time zone 'Europe/Stockholm') as dow_, 
EXTRACT (HOUR FROM to_timestamp(time_/1000)::timestamp with time zone at time zone 'Europe/Stockholm') as hour_,
totalnumberofsteps as steps,
lat_,lon_,accuracy_,
time_,
st_distance(st_makepoint(lat_,lon_)::geography, 
st_makepoint(lag(lat_) over (partition by user_id = $1 order by time_ ), lag(lon_) over (partition by user_id = $1 order by time_ ))::geography) as dist, 
(select transportation_type from triplegs_gt where user_id = $1
and type_of_tripleg>0 and from_time<=time_ and to_time>=time_ limit 1) as type_of_transport,
(select tripleg_id from triplegs_gt where user_id = $1
and type_of_tripleg>0 and from_time<=time_ and to_time>=time_ limit 1) as tripleg_id 
from location_table where user_id = $1 and accuracy_<=50
and (select tripleg_id from triplegs_gt where user_id = $1
and type_of_tripleg>0 and from_time<=time_ and to_time>=time_ limit 1) is not null ) as foo 
order by year_, month_, day_, dow_, hour_ 
),
meta_centralized as (
select *, time_ - lag(time_) over (partition by tripleg_id order by time_) as time_btw from  pre_meta_centralized ),


first_layer_of_separation as
(
select year_, month_, day_, dow_, hour_, type_of_transport, sum(steps) as steps, sum(dist) as dist, sum(co2_emission) as co2, sum(time_btw / 60000.0) as duration 
 from meta_centralized 
group by year_, month_, day_, dow_, hour_, type_of_transport 
order by year_, month_, day_, dow_, hour_ 
),

first_layer_of_separation_reg as (
select year_, month_, day_, dow_, hour_,
sum(steps) as steps, sum(co2) as co2, sum(duration) as duration 
from first_layer_of_separation 
group by year_, month_, day_, dow_, hour_),

stats_co2_steps_day_hour as 
(select dow_, hour_, avg(steps) as steps, avg(co2) as co2 from first_layer_of_separation_reg 
group by dow_, hour_
order by dow_, hour_ ),

stats_co2_steps_hour as 
(select hour_, avg(steps) as steps, avg(co2) as co2 from first_layer_of_separation_reg 
group by hour_
order by hour_ ), 

stats_co2_steps_day as 
(select dow_, avg(steps) as steps, avg(co2) as co2 from first_layer_of_separation_reg 
group by dow_
order by dow_ ) ,

stats_mode_day as 
(select dow_, type_of_transport, avg(duration) from first_layer_of_separation
group by dow_, type_of_transport
order by dow_, type_of_transport )  


select array_to_json (array_agg(r)) from (select 
(select array_to_json (array_agg(r)) from (select * from stats_mode_day ) r) as modes_per_day, 
(select array_to_json (array_agg(r)) from (select * from stats_co2_steps_day_hour) r) as co_steps
) r 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


/*INSERTION OPERATIONS*/

CREATE OR REPLACE FUNCTION ap_insert_artificial_user_point(
    latitude_ double precision,
    longitude_ double precision,
    userid bigint,
    time_ bigint,
    from_id bigint,
    to_id bigint)
  RETURNS bigint AS
$BODY$
INSERT INTO locations_added_by_user (latitude_ , longitude_,userid,time_,from_id, to_id)
values ($1, $2,$3, $4, $5, $6) RETURNING id
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_insert_personal_poi(
    type_ins text,
    name_ins text,
    lat_ins double precision,
    lon_ins double precision,
    declaring_user_id integer)
  RETURNS integer AS
$BODY$
INSERT INTO poi_personal(type_, name_, lat_, lon_, declaring_user_id, geom)
 values ($1, $2, $3, $4,$5, st_transform(st_setsrid(st_makepoint($4,$3),4326),3006)) 
RETURNING gid
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_insert_transportation_poi(
    type_ins text,
    name_ins text,
    lat_ins double precision,
    lon_ins double precision,
    transportation_lines text,
    transportation_types text,
    user_id integer)
  RETURNS integer AS
$BODY$
INSERT INTO poi_transportation(type_, name_, lat_, lon_, declared_by_user, transportation_lines, transportation_types, declaring_user_id,geom) values ($1, $2, $3, $4, true, $5, $6, $7, st_transform(st_setsrid(st_makepoint($4,$3),4326),3006)) 
RETURNING generated_id
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;  


CREATE OR REPLACE FUNCTION ap_insert_trip_gt(
    trip_id text,
    user_id bigint,
    from_point_id text,
    to_point_id text,
    from_time bigint,
    to_time bigint,
    type_of_trip smallint,
    purpose_id integer,
    destination_poi_id bigint,
    length_of_trip double precision,
    duration_of_trip double precision,
    number_of_triplegs integer)
  RETURNS text AS
$BODY$
  insert into trips_gt(trip_id, user_id, from_point_id, to_point_id, from_time, to_time, type_of_trip, purpose_id, destination_poi_id, length_of_trip, duration_of_trip, number_of_triplegs) 
  values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
  returning trip_id
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100; 



CREATE OR REPLACE FUNCTION ap_insert_tripleg_gt(
    tripleg_id text,
    trip_id text,
    user_id bigint,
    from_point_id bigint,
    to_point_id bigint,
    from_time bigint,
    to_time bigint,
    type_of_tripleg smallint,
    transportation_type integer,
    transition_poi_id bigint,
    length_of_tripleg double precision,
    duration_of_tripleg double precision)
  RETURNS text AS
$BODY$
  insert into triplegs_gt(tripleg_id, trip_id, user_id, from_point_id, to_point_id, from_time, to_time, type_of_tripleg, transportation_type, transition_poi_id, length_of_tripleg, duration_of_tripleg) 
  values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
  returning tripleg_id
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100;





CREATE OR REPLACE FUNCTION ap_insert_tripleg_gt(
    tripleg_id text,
    trip_id text,
    user_id bigint,
    from_point_id text,
    to_point_id text,
    from_time bigint,
    to_time bigint,
    type_of_tripleg smallint,
    transportation_type integer,
    transition_poi_id bigint,
    length_of_tripleg double precision,
    duration_of_tripleg double precision)
  RETURNS text AS
$BODY$
  insert into triplegs_gt(tripleg_id, trip_id, user_id, from_point_id, to_point_id, from_time, to_time, type_of_tripleg, transportation_type, transition_poi_id, length_of_tripleg, duration_of_tripleg) 
  values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
  returning tripleg_id
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION ap_insert_web_log(
    userid integer,
    log_date bigint,
    log_message text,
    back_front text,
    extra_stack text)
  RETURNS integer AS
$BODY$
INSERT INTO log_table_web (userid, log_date, log_message, back_front, extra_stack) 
 values ($1, $2, $3, $4,$5) 
RETURNING userid
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;



/*UPDATE OPERATIONS*/

CREATE OR REPLACE FUNCTION ap_update_artificial_user_point(
    id integer,
    latitude_ double precision,
    longitude_ double precision)
  RETURNS void AS
$BODY$
UPDATE locations_added_by_user SET latitude_ = $2, longitude_= $3  where id = $1
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_update_personal_poi(
    osm_id integer,
    type_update text,
    name_update text,
    lat_update double precision,
    lon_update double precision)
  RETURNS void AS
$BODY$
UPDATE poi_personal SET type_=$2, name_=$3, lat_=$4, lon_=$5,
geom=st_transform(st_setsrid(st_makepoint($5,$4),4326),3006) where gid = $1  
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_update_transportation_poi(
    id_ins bigint,
    type_ins text,
    name_ins text,
    lat_ins double precision,
    lon_ins double precision,
    transportation_lines text,
    transportation_types text)
  RETURNS void AS
$BODY$
UPDATE poi_transportation SET type_= $2, name_=$3, lat_=$4, lon_=$5, transportation_lines=$6, transportation_types=$7 where generated_id = $1
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_update_trip_gt(
    trip_id text,
    user_id bigint,
    from_point_id text,
    to_point_id text,
    from_time bigint,
    to_time bigint,
    type_of_trip smallint,
    purpose_id integer,
    destination_poi_id bigint,
    length_of_trip double precision,
    duration_of_trip double precision,
    number_of_triplegs integer)
  RETURNS text AS
$BODY$
  update trips_gt set (user_id, from_point_id, to_point_id, from_time, to_time, type_of_trip, purpose_id, destination_poi_id, length_of_trip, duration_of_trip, number_of_triplegs) 
  = ($2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
  where trip_id = $1
  returning trip_id
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION ap_update_tripleg_gt(
    tripleg_id text,
    trip_id text,
    user_id bigint,
    from_point_id bigint,
    to_point_id bigint,
    from_time bigint,
    to_time bigint,
    type_of_tripleg smallint,
    transportation_type integer,
    transition_poi_id bigint,
    length_of_tripleg double precision,
    duration_of_tripleg double precision)
  RETURNS text AS
$BODY$
  update triplegs_gt set (trip_id, user_id, from_point_id, to_point_id, from_time, to_time, type_of_tripleg, transportation_type, transition_poi_id, length_of_tripleg, duration_of_tripleg) 
  = ($2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
  where tripleg_id = $1
  returning tripleg_id
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION ap_update_tripleg_gt(
    tripleg_id text,
    trip_id text,
    user_id bigint,
    from_point_id text,
    to_point_id text,
    from_time bigint,
    to_time bigint,
    type_of_tripleg smallint,
    transportation_type integer,
    transition_poi_id bigint,
    length_of_tripleg double precision,
    duration_of_tripleg double precision)
  RETURNS text AS
$BODY$
  update triplegs_gt set (trip_id, user_id, from_point_id, to_point_id, from_time, to_time, type_of_tripleg, transportation_type, transition_poi_id, length_of_tripleg, duration_of_tripleg) 
  = ($2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
  where tripleg_id = $1
  returning tripleg_id
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100;



/*PAGINATION OPERATIONS*/



CREATE OR REPLACE FUNCTION ap_get_next_trip(
    user_id bigint,
    date_from bigint)
  RETURNS json AS
$BODY$
with
user_id as (select $1 as user_id),
last_annotated_ground_truth_trip as (select t.* from trips_gt as t, user_id as u where t.user_id = u.user_id order by to_time desc limit 1),
ground_truth_trips_that_need_annotation as (select t.* from trips_gt as t, user_id as u where  t.user_id = u.user_id and destination_poi_id=-1),
ground_truth_trips_that_do_not_need_annotation as (select trip_id, 'verified'::text as type_of_selection, from_time, to_time from trips_gt as t, user_id as u where destination_poi_id>=0 and u.user_id = t.user_id order by from_time, to_time),
last_annotated_time as (select case when exists(select to_time from last_annotated_ground_truth_trip) then (select to_time from last_annotated_ground_truth_trip)
else 0 end as to_time),
infered_trips_that_needs_annotation as (select t1.* from trips_inf as t1, last_annotated_time as t2, user_id as u where t1.from_time>=t2.to_time and t1.user_id = u.user_id), 
all_trips_that_need_annotation as (select trip_id::text, 'inferred'::text as type_of_selection, from_time, to_time from infered_trips_that_needs_annotation union all
select trip_id, 'ground_truth'::text as type_of_selection, from_time, to_time from ground_truth_trips_that_need_annotation
order by from_time, to_time),
pre_paginated_trips as (select * from ground_truth_trips_that_do_not_need_annotation union all
select * from all_trips_that_need_annotation),
paginated_trips as (select *, row_number() over() from pre_paginated_trips),
last_row as (select row_number as row_number from paginated_trips where type_of_selection<>'verified' limit 1), -- this relies on the assumption that it is ordered 
trips_of_interest as (select * from paginated_trips where to_time>$2 order by row_number asc limit 2) --- get next 2 trips
select array_to_json(array_agg(t.trips)) from (select case when type_of_selection='inferred' then ap_get_trip_inf_json(trip_id::integer) else ap_get_trip_gt_json(trip_id) end as trips from trips_of_interest) as t 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION ap_get_prev_trip(
    user_id bigint,
    date_from bigint)
  RETURNS json AS
$BODY$
with
user_id as (select $1 as user_id),
last_annotated_ground_truth_trip as (select t.* from trips_gt as t, user_id as u where t.user_id = u.user_id order by to_time desc limit 1),
ground_truth_trips_that_need_annotation as (select t.* from trips_gt as t, user_id as u where  t.user_id = u.user_id and destination_poi_id=-1 and type_of_trip>0),
ground_truth_trips_that_do_not_need_annotation as (select trip_id, 'verified'::text as type_of_selection, from_time, to_time from trips_gt as t, user_id as u where (destination_poi_id>=0 or type_of_trip=0) and u.user_id = t.user_id order by from_time, to_time),
last_annotated_time as (select case when exists(select to_time from last_annotated_ground_truth_trip) then (select to_time from last_annotated_ground_truth_trip)
else 0 end as to_time),
infered_trips_that_needs_annotation as (select t1.* from trips_inf as t1, last_annotated_time as t2, user_id as u where t1.from_time>=t2.to_time and t1.user_id = u.user_id), 
all_trips_that_need_annotation as (select trip_id::text, 'inferred'::text as type_of_selection, from_time, to_time from infered_trips_that_needs_annotation union all
select trip_id, 'ground_truth'::text as type_of_selection, from_time, to_time from ground_truth_trips_that_need_annotation
order by from_time, to_time),
pre_paginated_trips as (select * from ground_truth_trips_that_do_not_need_annotation union all
select * from all_trips_that_need_annotation),
paginated_trips as (select *, row_number() over() from pre_paginated_trips),
last_row as (select row_number as row_number from paginated_trips where type_of_selection<>'verified' limit 1), -- this relies on the assumption that it is ordered 
trips_of_interest as (select * from paginated_trips where from_time<$2 order by row_number desc limit 2) -- get previous 2 trips 
select array_to_json(array_agg(t.trips)) from (select case when type_of_selection='inferred' then ap_get_trip_inf_json(trip_id::integer) else ap_get_trip_gt_json(trip_id) end as trips from trips_of_interest) as t 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION ap_get_trips_to_process_for_user_table(IN user_id bigint)
  RETURNS TABLE(trip_id text, type_of_selection text) AS
$BODY$
with
user_id as (select $1 as user_id),
last_annotated_ground_truth_trip as (select t.* from trips_gt as t, user_id as u where t.user_id = u.user_id order by to_time desc limit 1),
ground_truth_trips_that_need_annotation as (select distinct on (trip_id) t.* from trips_gt as t, user_id as u where  t.user_id = u.user_id and destination_poi_id=-1 and type_of_trip<>0),
ground_truth_trips_that_do_not_need_annotation as (select distinct on (trip_id) trip_id, 'verified'::text as type_of_selection, from_time, to_time from trips_gt as t, user_id as u where (destination_poi_id>=0 or type_of_trip=0) and u.user_id = t.user_id),
last_annotated_time as (select case when exists(select to_time from last_annotated_ground_truth_trip) then (select to_time from last_annotated_ground_truth_trip)
else 0 end as to_time),
infered_trips_that_needs_annotation as (select t1.* from trips_inf as t1, last_annotated_time as t2, user_id as u where t1.to_time>t2.to_time and t1.user_id = u.user_id), 
all_trips_that_need_annotation as (select trip_id::text, 'inferred'::text as type_of_selection, from_time, to_time from infered_trips_that_needs_annotation union all
select trip_id, 'ground_truth'::text as type_of_selection, from_time, to_time from ground_truth_trips_that_need_annotation
order by from_time, to_time),
pre_paginated_trips as (select * from ground_truth_trips_that_do_not_need_annotation union all
select * from all_trips_that_need_annotation),
p1_paginated_trips as (select *, row_number() over() from pre_paginated_trips),
paginated_trips as (select trip_id, case when type_of_selection = 'verified' and lag(type_of_selection,1) over () =lead(type_of_selection,1) over() then lead(type_of_selection) over () else type_of_selection end as type_of_selection,
to_time, from_time, row_number() over () from (select * from p1_paginated_trips order by row_number) as foo ),
last_row as (select case when exists(select row_number as row_number from paginated_trips where type_of_selection<>'verified' limit 1)then (select row_number as row_number from paginated_trips where type_of_selection<>'verified' limit 1)
else (select max(row_number)/2 from paginated_trips) end as row_number) -- this relies on the assumption that it is ordered 
select trip_id, type_of_selection from paginated_trips as pt, last_row as r where pt.row_number between r.row_number - 4 and r.row_number+ 5 -- to verify if this makes sense 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;





CREATE OR REPLACE FUNCTION ap_get_trips_to_process_for_user_table_trip_type(IN user_id bigint)
  RETURNS TABLE(trip_id text, type_of_selection text, type_of_trip smallint) AS
$BODY$
with
user_id as (select $1 as user_id),
last_annotated_ground_truth_trip as (select t.* from trips_gt as t, user_id as u where t.user_id = u.user_id order by to_time desc limit 1),
ground_truth_trips_that_need_annotation as (select t.* from trips_gt as t, user_id as u where  t.user_id = u.user_id and destination_poi_id=-1 and type_of_trip<>0),
ground_truth_trips_that_do_not_need_annotation as (select trip_id, 'verified'::text as type_of_selection, from_time, to_time, type_of_trip from trips_gt as t, user_id as u where (destination_poi_id>=0 or type_of_trip=0) and u.user_id = t.user_id order by from_time, to_time),
last_annotated_time as (select case when exists(select to_time from last_annotated_ground_truth_trip) then (select to_time from last_annotated_ground_truth_trip)
else 0 end as to_time),
infered_trips_that_needs_annotation as (select t1.* from trips_inf as t1, last_annotated_time as t2, user_id as u where t1.to_time>t2.to_time and t1.user_id = u.user_id), 
all_trips_that_need_annotation as (select trip_id::text, 'inferred'::text as type_of_selection, from_time, to_time, type_of_trip from infered_trips_that_needs_annotation union all
select trip_id, 'ground_truth'::text as type_of_selection, from_time, to_time, type_of_trip from ground_truth_trips_that_need_annotation
order by from_time, to_time),
pre_paginated_trips as (select * from ground_truth_trips_that_do_not_need_annotation union all
select * from all_trips_that_need_annotation),
p1_paginated_trips as (select *, row_number() over() from pre_paginated_trips),
paginated_trips as (select trip_id, type_of_trip, case when type_of_selection = 'verified' and lag(type_of_selection,1) over () =lead(type_of_selection,1) over() then lead(type_of_selection) over () else type_of_selection end as type_of_selection,
to_time, from_time, row_number() over () from (select * from p1_paginated_trips order by from_time, to_time) as foo ),
last_row as (select case when exists(select row_number as row_number from paginated_trips where type_of_selection<>'verified' limit 1)then (select row_number as row_number from paginated_trips where type_of_selection<>'verified' limit 1)
else (select max(row_number)/2 from paginated_trips) end as row_number) -- this relies on the assumption that it is ordered 
select trip_id, type_of_selection, type_of_trip from paginated_trips as pt, last_row as r where pt.row_number between r.row_number - 4 and r.row_number+ 5 -- to verify if this makes sense 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;




CREATE OR REPLACE FUNCTION ap_get_server_response_for_user(userid integer)
  RETURNS json AS
$BODY$
with 
user_id as (select $1 as user_id),
last_annotated_ground_truth_trip as (select t.* from trips_gt as t, user_id as u where t.user_id = u.user_id order by to_time desc limit 1),
ground_truth_trips_that_need_annotation as (select t.* from trips_gt as t, user_id as u where  t.user_id = u.user_id and destination_poi_id=-1 and type_of_trip<>0),
ground_truth_trips_that_do_not_need_annotation as (select trip_id, 'verified'::text as type_of_selection, from_time, to_time, type_of_trip from trips_gt as t, user_id as u where (destination_poi_id>=0 or type_of_trip=0) and u.user_id = t.user_id order by from_time, to_time),
last_annotated_time as (select case when exists(select to_time from last_annotated_ground_truth_trip) then (select to_time from last_annotated_ground_truth_trip)
else 0 end as to_time),
infered_trips_that_needs_annotation as (select t1.* from trips_inf as t1, last_annotated_time as t2, user_id as u where t1.from_time>=t2.to_time and t1.user_id = u.user_id), 
all_trips_that_need_annotation as (select trip_id::text, 'inferred'::text as type_of_selection, from_time, to_time, type_of_trip from infered_trips_that_needs_annotation union all
select trip_id, 'ground_truth'::text as type_of_selection, from_time, to_time, type_of_trip from ground_truth_trips_that_need_annotation
order by from_time, to_time),
pre_paginated_trips as (select * from ground_truth_trips_that_do_not_need_annotation union all
select * from all_trips_that_need_annotation),
p1_paginated_trips as (select *, row_number() over() from pre_paginated_trips),
paginated_trips as (select trip_id, case when type_of_selection = 'verified' and lag(type_of_selection,1) over () =lead(type_of_selection,1) over() then lead(type_of_selection) over () else type_of_selection end as type_of_selection,
to_time, from_time, type_of_trip, row_number() over () from (select * from p1_paginated_trips order by from_time, to_time) as foo ),

trips_to_process as (select count(*) as ct from paginated_trips where type_of_selection<>'verified' and type_of_trip>0),
trips as (select case when type_of_selection = 'inferred' then ap_get_trip_inf_json(trip_id::integer)
else ap_get_trip_gt_json(trip_id) end as trip from ap_get_trips_to_process_for_user_table($1)),

go_to_index as (select case when min(idx) is null then 0 else min(idx) end as idx from (select * from (select *, row_number() over () as idx from ap_get_trips_to_process_for_user_table_trip_type($1)) as foo where type_of_selection<>'verified' and type_of_trip<>0) as foo),
actual_index as (select case when exists(select idx from go_to_index) then (select idx from go_to_index) else 0 end as idx)


select row_to_json(r) from 
(select idx.idx as go_to_index, tp.ct as trips_to_process, array_to_json(array_agg(t.trip)) as trips 
from trips_to_process as tp, trips as t, actual_index as idx group by tp.ct, idx.idx) r 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100; 
