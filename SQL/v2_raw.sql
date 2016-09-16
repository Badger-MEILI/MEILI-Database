/*
** SCHEMA DEFINITION
*/
create schema if not exists raw_data; 
comment on schema raw_data is
'For raw measurements that are not modified (locations, user credentials)';

/*
** TABLE DEFINITIONS
*/
CREATE TABLE if not exists raw_data.location_table
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
  provider text
);

Comment on table raw_data.location_table is 
'stores the locations retrieved from the clients';

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext; 

CREATE TABLE if not exists raw_data.user_table
(
  id serial NOT NULL,
  username citext NOT NULL UNIQUE,
  password text NOT NULL,
  phone_model citext NOT NULL,
  phone_os text,
  CONSTRAINT user_table_pkey PRIMARY KEY (id)
);

comment on table raw_data.user_table is 
'stores the credentials of the user, password is hashed (needs pgcrypto), citext is used for case insensitive storage of email addresses'; 

/*
** FUNCTION DEFINTIONS
*/

create or replace function raw_data.register_user(username citext, password text, phone_model text, phone_os text)
returns integer as 
$fct_body$
	INSERT INTO raw_data.user_TABLE (username, password, phone_model, phone_os)
	VALUES ($1, crypt($2, gen_salt('bf',8)), $3, $4)
	RETURNING id;
$fct_body$
LANGUAGE SQL;

comment on function raw_data.register_user(username citext, password text, phone_model text, phone_os text) is 
'inserts a new user with hashed password and returns the user_id for api_end_point related to register_user';
-- foo example 
-- select register_user as id from raw_data.register_user('adi@kth.se', 'adi', 'android', 'android model');

create or replace function raw_data.login_user(username citext, password text)
returns integer as 
$fct_body$
	SELECT id from raw_data.user_TABLE 
	where 
	username = $1
	and password = crypt($2, password);
$fct_body$
LANGUAGE SQL;

comment on function raw_data.login_user(username citext, password text) is 
'checks if the credentials are correct and returns the user_id for api_end_point related to login_user';

-- foo example 
-- select login_user as id from raw_data.login_user('adi@kth.se', 'adi');