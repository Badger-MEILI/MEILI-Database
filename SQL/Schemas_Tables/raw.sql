CREATE SCHEMA IF NOT EXISTS raw_data;

CREATE TABLE IF NOT EXISTS raw_data.user_table
(
  id serial NOT NULL,
  username citext NOT NULL,
  password text NOT NULL,
  phone_model citext NOT NULL,
  phone_os text,
  CONSTRAINT user_table_pkey PRIMARY KEY (id),
  CONSTRAINT user_table_username_key UNIQUE (username)
);

COMMENT ON TABLE raw_data.user_table
  IS 'stores the credentials of the user, password is hashed (needs pgcrypto), citext is used for case insensitive storage of email addresses';

CREATE TABLE IF NOT EXISTS raw_data.location_table
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
  provider text,
  CONSTRAINT location_table_pkey PRIMARY KEY (id),
  CONSTRAINT location_table_user_id_fkey FOREIGN KEY (user_id)
      REFERENCES raw_data.user_table (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
);


COMMENT ON TABLE raw_data.location_table
  IS 'stores the locations retrieved from the clients';
