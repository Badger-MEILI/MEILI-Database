create schema if not exists apiv2; 
comment on schema apiv2 is
'Stores the data that can be used in the CRUD operations for trips and triplegs';

CREATE EXTENSION IF NOT EXISTS postgis; 

CREATE TABLE IF NOT EXISTS apiv2.pois
(
  gid serial NOT NULL,
  type_ text,
  name_ text,
  lat_ double precision,
  lon_ double precision,
  user_id bigint,
  osm_id bigint DEFAULT 0,
  is_personal boolean,
  geom geometry(Point),
  CONSTRAINT pois_pkey PRIMARY KEY (gid)
);

COMMENT ON TABLE apiv2.pois is 
'Stores the POIs used by the app';

CREATE TABLE IF NOT EXISTS apiv2.poi_transportation
(
  gid serial NOT NULL,
  osm_id bigint DEFAULT 0,
  type_ text,
  name_ text,
  lat_ double precision,
  lon_ double precision,
  declared_by_user boolean DEFAULT false,
  transportation_lines text,
  transportation_types text,
  declaring_user_id integer,
  type_sv text,
  geom geometry(Point),
  CONSTRAINT poi_transportation_pkey PRIMARY KEY (gid)
);
COMMENT ON TABLE apiv2.poi_transportation is 
'Stores the transportation POIs used by the app';

CREATE TABLE IF NOT EXISTS apiv2.purpose_table
(
  id smallint,
  name_ text,
  name_sv text,
  CONSTRAINT purpose_table_pkey PRIMARY KEY (id)
);
COMMENT ON TABLE apiv2.purpose_table is 
'Stores the purpose schema';

CREATE TABLE IF NOT EXISTS apiv2.travel_mode_table
(
  id smallint,
  name_ text,
  name_sv text,
  CONSTRAINT travel_mode_table_pkey PRIMARY KEY (id)
);
COMMENT ON TABLE apiv2.travel_mode_table is 
'Stores the travel mode schema';


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
  trip_id serial NOT NULL,
  parent_trip_id bigint,
  CONSTRAINT trips_inf_pkey PRIMARY KEY (trip_id),
  CONSTRAINT trips_inf_destination_poi_id_fkey FOREIGN KEY (destination_poi_id)
      REFERENCES apiv2.pois (gid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT trips_inf_purpose_id_fkey FOREIGN KEY (purpose_id)
      REFERENCES apiv2.purpose_table (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT trips_inf_user_id_fkey FOREIGN KEY (user_id)
      REFERENCES raw_data.user_table (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT trip_temporal_integrity CHECK (from_time <= to_time)
);
COMMENT ON TABLE apiv2.trips_inf is 
'Stores the trips that have been detected by the segmentation algorithm';


CREATE TABLE IF NOT EXISTS apiv2.triplegs_inf
(
  user_id integer,
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
  trip_id integer,
  parent_tripleg_id bigint,
  CONSTRAINT triplegs_inf_pkey PRIMARY KEY (tripleg_id),
  CONSTRAINT triplegs_inf_transition_poi_id_fkey FOREIGN KEY (transition_poi_id)
      REFERENCES apiv2.poi_transportation (gid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT triplegs_inf_transportation_type_fkey FOREIGN KEY (transportation_type)
      REFERENCES apiv2.travel_mode_table (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT tripleg_temporal_integrity CHECK (from_time <= to_time)
);
COMMENT ON TABLE apiv2.triplegs_inf is 
'Stores the triplegs that have been detected by the segmentation algorithm';

CREATE TABLE IF NOT EXISTS apiv2.trips_gt
(
trip_id serial NOT NULL,
  trip_inf_id integer,
  user_id bigint,
  from_point_id text,
  to_point_id text,
  from_time bigint,
  to_time bigint,
  type_of_trip smallint,
  purpose_id integer NOT NULL,
  destination_poi_id bigint NOT NULL,
  length_of_trip double precision,
  duration_of_trip double precision,
  number_of_triplegs integer,
  CONSTRAINT trips_gt_pkey PRIMARY KEY (trip_id),
  CONSTRAINT trips_gt_trip_inf_id_fkey FOREIGN KEY (trip_inf_id)
      REFERENCES apiv2.trips_inf (trip_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT trips_gt_user_id_fkey FOREIGN KEY (user_id)
      REFERENCES raw_data.user_table (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT trips_gt_trip_inf_id_unique UNIQUE (trip_inf_id)
);
COMMENT ON TABLE apiv2.trips_gt is 
'Stores the trips that have been annotated by the user';

CREATE TABLE IF NOT EXISTS apiv2.triplegs_gt
(
  tripleg_id serial NOT NULL,
  tripleg_inf_id integer,
  trip_id integer,
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
  CONSTRAINT triplegs_gt_trip_id_fkey FOREIGN KEY (trip_id)
      REFERENCES apiv2.trips_gt (trip_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT triplegs_gt_tripleg_inf_id_fkey FOREIGN KEY (tripleg_inf_id)
      REFERENCES apiv2.triplegs_inf (tripleg_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT valid_travel_mode CHECK (type_of_tripleg = 0 OR transportation_type IS NOT NULL)
);

COMMENT ON TABLE apiv2.triplegs_gt is 
'Stores the triplegs that have been annotated by the user';

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
        any (select trip_inf_id from apiv2.processed_trips); 
        Comment on view apiv2.unprocessed_trips is 
'Used to serve the annotated triplegs per trip - selection per trip_id';
