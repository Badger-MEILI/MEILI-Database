/*
** SCHEMA DEFINITION
*/
create schema if not exists apiv2; 
comment on schema apiv2 is
'Stores the data that can be used in the CRUD operations for trips and triplegs';

CREATE TABLE IF NOT EXISTS apiv2.trips_inf
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
  trip_id serial NOT NULL primary key
);
COMMENT ON TABLE apiv2.trips_inf is 
'Stores the trips that have been detected by the segmentation algorithm';

CREATE TABLE IF NOT EXISTS apiv2.triplegs_inf
(
  user_id int references raw_data.user_table(id),
  from_point_id bigint,
  to_point_id bigint,
  from_time bigint,
  to_time bigint,
  type_of_tripleg smallint,
  transportation_type integer,
  transition_poi_id bigint,
  length_of_tripleg double precision,
  duration_of_tripleg double precision,
  tripleg_id serial NOT NULL primary key,
  trip_id int references apiv2.trips_inf(trip_id)
  );
COMMENT ON TABLE apiv2.triplegs_inf is 
'Stores the triplegs that have been detected by the segmentation algorithm';

CREATE TABLE IF NOT EXISTS apiv2.trips_gt
(
  trip_id serial not null primary key,
  trip_inf_id int references apiv2.trips_inf(trip_id),
  user_id bigint references raw_data.user_table(id),
  from_point_id text,
  to_point_id text,
  from_time bigint,
  to_time bigint,
  type_of_trip smallint,
  purpose_id integer,
  destination_poi_id bigint,
  length_of_trip double precision,
  duration_of_trip double precision,
  number_of_triplegs integer 
);
COMMENT ON TABLE apiv2.trips_gt is 
'Stores the trips that have been annotated by the user';

CREATE TABLE IF NOT EXISTS apiv2.triplegs_gt
(
  tripleg_id serial not null,
  tripleg_inf_id int references apiv2.triplegs_inf(tripleg_id),
  trip_id int references apiv2.trips_gt(trip_id),
  user_id bigint,
  from_point_id text,
  to_point_id text,
  from_time bigint,
  to_time bigint,
  type_of_tripleg smallint,
  transportation_type integer,
  transition_poi_id bigint,
  length_of_tripleg double precision,
  duration_of_tripleg double precision 
);

COMMENT ON TABLE apiv2.triplegs_gt is 
'Stores the triplegs that have been annotated by the user';

CREATE EXTENSION IF NOT EXISTS postgis; 

CREATE TABLE IF NOT EXISTS apiv2.pois
(
  gid serial NOT NULL primary key,
  type_ text,
  name_ text,
  lat_ double precision,
  lon_ double precision,
  user_id bigint,
  osm_id bigint default 0,
  is_personal boolean,
  geom geometry(Point,3006)
);

COMMENT ON TABLE apiv2.pois is 
'Stores the POIs used by the app';

CREATE TABLE IF NOT EXISTS apiv2.poi_transportation
(
gid serial NOT NULL primary key,
  osm_id bigint default 0,
  type_ text,
  name_ text,
  lat_ double precision,
  lon_ double precision,
  declared_by_user boolean DEFAULT false,
  transportation_lines text,
  transportation_types text,
  declaring_user_id integer,
  type_sv text,
  geom geometry(Point,3006)
);
COMMENT ON TABLE apiv2.poi_transportation is 
'Stores the transportation POIs used by the app';

CREATE TABLE IF NOT EXISTS apiv2.purpose_table
(
  id smallint,
  name_ text,
  name_sv text
);
COMMENT ON TABLE apiv2.purpose_table is 
'Stores the purpose schema';

CREATE TABLE IF NOT EXISTS apiv2.travel_mode_table
(
  id smallint,
  name_ text,
  name_sv text
);
COMMENT ON TABLE apiv2.travel_mode_table is 
'Stores the travel mode schema';

/*
Unannotated trips and triplegs for pagination 
*/

create or replace view apiv2.unprocessed_trips as
        select * from apiv2.trips_inf as ti where
        from_time>= (
        select coalesce(max(tg.to_time),0) from apiv2.trips_gt tg where
        tg.user_id = ti.user_id
        and tg.type_of_trip = 1)
        and ti.type_of_trip = 1;
Comment on view apiv2.unprocessed_trips is 
'Used to serve the unannotated trips to the user on the pagination - selection by user_id';

create or replace view apiv2.unprocessed_triplegs as
        select * from apiv2.triplegs_inf where trip_id =
        any (select trip_id from apiv2.unprocessed_trips);
Comment on view apiv2.unprocessed_trips is 
'Used to serve the unprocessed triplegs per trip - selection per trip_id';

/*
Annotated trips and triplegs annotation 
*/
-- view that will serve the annotated trips to the user on request
create or replace view apiv2.processed_trips as
        select * from apiv2.trips_gt where type_of_trip = 1;
Comment on view apiv2.unprocessed_trips is 
'Used to serve the annotated trips of a user - selection per user_id';

-- view that will serve the annotated triplegs per trip
create or replace view apiv2.processed_triplegs as
        select * from apiv2.triplegs_inf where trip_id =
        any (select trip_id from apiv2.processed_trips); 
        Comment on view apiv2.unprocessed_trips is 
'Used to serve the annotated triplegs per trip- selection per trip_id';