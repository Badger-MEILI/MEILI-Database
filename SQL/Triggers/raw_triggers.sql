CREATE OR REPLACE FUNCTION apiv2.tg_deleted_user()
  RETURNS trigger AS
$BODY$ 
DECLARE 
BEGIN 
	
	DELETE FROM apiv2.trips_inf where user_id = OLD.id;
	
	DELETE FROM apiv2.triplegs_inf where user_id = OLD.id;
	
	RETURN OLD;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION apiv2.tg_deleted_user() IS 'CASCADES THE DELETION OF A USER ID TO DELETE ALL THE TRIPS AND TRIPLEGS BELONGING TO THE USER -> ONLY FOR TESTING PURPOSES, SHOULD NOT BE USED IN PRODUCTION';

DROP TRIGGER IF EXISTS trg_deleted_user ON raw_data.user_table;

CREATE TRIGGER trg_deleted_user
  BEFORE DELETE
  ON raw_data.user_table
  FOR EACH ROW
  EXECUTE PROCEDURE apiv2.tg_deleted_user();
