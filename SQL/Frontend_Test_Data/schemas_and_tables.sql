CREATE SCHEMA IF NOT EXISTS tests;

 CREATE TABLE IF NOT EXISTS tests.trips_inf 
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
  trip_id bigint,
  parent_trip_id bigint);

  CREATE TABLE IF NOT EXISTS tests.triplegs_inf 
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
  tripleg_id bigint,
  trip_id integer,
  parent_tripleg_id bigint
  );

  CREATE TABLE IF NOT EXISTS tests.user_table
(
  id bigint,
  username citext,
  password text,
  phone_model text,
  phone_os text
);

CREATE TABLE IF NOT EXISTS tests.location_table
(
  id bigint,
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
  provider text
);

-- USERNAME 'test@test.test'
-- PASSWORD 'test' 

CREATE OR REPLACE FUNCTION tests.refresh_test_data()
RETURNS VOID AS 
$bd$
BEGIN
	ALTER TABLE apiv2.trips_inf DISABLE trigger all;
	ALTER TABLE apiv2.triplegs_inf DISABLE trigger all;

	DELETE FROM apiv2.triplegs_gt where user_id =0;
	DELETE FROM apiv2.trips_gt where user_id =0;
	DELETE FROM apiv2.triplegs_inf where user_id =0;
	DELETE FROM apiv2.trips_inf where user_id =0;
	DELETE FROM raw_data.user_table where id =0; 

	ALTER TABLE apiv2.trips_inf enable trigger all;
	ALTER TABLE apiv2.triplegs_inf enable trigger all;

	-- BEWARE OF MONKEY CODE 
	INSERT INTO raw_data.user_table SELECT * FROM tests.user_table;
	INSERT INTO raw_data.location_table SELECT -1 * id, upload, accuracy_, altitude_, bearing_, lat_, lon_, time_, speed_, satellites_, user_id,
			size, totalismoving, totalmax, totalmean, totalmin, totalnumberofpeaks, totalnumberofsteps, totalstddev, xismoving, xmaximum,
			xmean, xminimum, xnumberofpeaks, xstddev, yismoving, ymax, ymean, ymin, ynumberofpeaks, ystddev, zismoving, zmax, zmean, zmin, znumberofpeaks,
			zstddev, provider FROM tests.location_table;
	INSERT INTO apiv2.trips_inf SELECT user_id, -1 * from_point_id, -1 * to_point_id, from_time, to_time, type_of_trip, purpose_id, destination_poi_id, length_of_trip,
			duration_of_trip, number_of_triplegs, -1 * trip_id, -1 * parent_trip_id from tests.trips_inf;
	INSERT INTO apiv2.triplegs_inf SELECT user_id, -1 * from_point_id, -1 * to_point_id, from_time, to_time, type_of_tripleg, transportation_type, transition_poi_id,
			length_of_tripleg, duration_of_tripleg, -1 * tripleg_id, -1 * trip_id, -1 * parent_tripleg_id from tests.triplegs_inf;
END;
$bd$
LANGUAGE plpgsql;