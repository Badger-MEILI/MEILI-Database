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
  trip_id serial NOT NULL
);
COMMENT ON TABLE apiv2.trips_inf is 
'Stores the trips that have been detected by the segmentation algorithm';

CREATE TABLE IF NOT EXISTS apiv2.triplegs_inf
(
  user_id int references raw.user_table(id),
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
  trip_id int references apiv2.trips_inf(trip_id)
  );
COMMENT ON TABLE apiv2.triplegs_inf is 
'Stores the triplegs that have been detected by the segmentation algorithm';

CREATE TABLE apiv2.trips_gt
(
  trip_id serial not null,
  trip_inf_id int references apiv2.trips_inf(trip_id),
  user_id bigint references raw.user_table(id),
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

CREATE TABLE apiv2.triplegs_gt
(
  tripleg_id serial not null,
  tripleg_inf_id int references apiv2.triplegs_inf(tripleg_id)
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

/*
Unannotated trips and triplegs for pagination 
*/

create view apiv2.unprocessed_trips as
        select * from trips_inf as ti where
        from_time>= (
        select max(tg.to_time) from apiv2.trips_gt tg where
        tg.user_id = ti.user_id
        and tg.type_of_trip = 1)
        and ti.type_of_trip = 1;
Comment on view apiv2.unprocessed_trips is 
'Used to serve the unannotated trips to the user on the pagination - selection by user_id';

create view apiv2.unprocessed_triplegs as
        select * from apiv2.triplegs_inf where trip_id =
        any (select trip_id from apiv2.unprocessed_trips);
Comment on view apiv2.unprocessed_trips is 
'Used to serve the unprocessed triplegs per trip - selection per trip_id';

/*
Annotated trips and triplegs annotation 
*/
-- view that will serve the annotated trips to the user on request
create view apiv2.processed_trips as
        select * from apiv2.trips_gt where type_of_trip = 1;
Comment on view apiv2.unprocessed_trips is 
'Used to serve the annotated trips of a user - selection per user_id';

-- view that will serve the annotated triplegs per trip
create view apiv2.processed_triplegs as
        select * from apiv2.triplegs_inf where trip_id =
        any (select trip_id from apiv2.processed_trips); 
        Comment on view apiv2.unprocessed_trips is 
'Used to serve the annotated triplegs per trip- selection per trip_id';