CREATE OR REPLACE FUNCTION raw_data.login_user(
    username citext,
    password text)
  RETURNS integer AS
$BODY$
	SELECT id from raw_data.user_TABLE 
	where 
	username = $1
	and password = crypt($2, password);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION raw_data.login_user(citext, text) IS 'checks if the credentials are correct and returns the user_id for the api end point related to login_user';

CREATE OR REPLACE FUNCTION raw_data.register_user(
    username citext,
    password text,
    phone_model text,
    phone_os text)
  RETURNS integer AS
$BODY$
	INSERT INTO raw_data.user_TABLE (username, password, phone_model, phone_os)
	VALUES ($1, crypt($2, gen_salt('bf',8)), $3, $4)
	RETURNING id;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

COMMENT ON FUNCTION raw_data.register_user(citext, text, text, text) IS 'inserts a new user with hashed password and returns the user_id for the api end point related to register_user';


CREATE OR REPLACE FUNCTION raw_data.update_user_password(
    username citext,
    password text)
  RETURNS boolean AS
$BODY$
	UPDATE raw_data.user_table 
	SET PASSWORD = crypt($2, gen_salt('bf',8))
	WHERE username = $1
	RETURNING true;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
