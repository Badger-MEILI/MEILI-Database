-- TRIPS TRIGGERS

CREATE OR REPLACE FUNCTION apiv2.tg_deleted_trip()
  RETURNS trigger AS
$BODY$ 
DECLARE
prev_trip_id integer;
next_trip_id integer; 
BEGIN 
	
	IF OLD.type_of_trip = 1 THEN  
		-- previous stationary tripleg
		prev_trip_id := trip_id from apiv2.trips_inf where user_id = OLD.user_id
			and type_of_trip = 0 and to_time <= OLD.from_time order by to_time desc limit 1;
		-- next stationary tripleg
		next_trip_id := trip_id from apiv2.trips_inf where user_id= OLD.user_id
			and type_of_trip = 0 and from_time >= OLD.to_time order by from_time asc limit 1;

		-- if there is no previous trip or if there is no next trip, it is safe to delete 
		IF prev_trip_id is not null and next_trip_id is not null THEN 
			-- update the previous stationary trip end time to cover the next trip end time 
			UPDATE apiv2.trips_inf set to_time = (select to_time from apiv2.trips_inf where trip_id = next_trip_id) where trip_id = prev_trip_id;
			-- delete the next stationary trip  
			DELETE FROM apiv2.trips_inf where trip_id = next_trip_id; 
		END IF;
	return OLD; 
	END IF;
	
  return OLD;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.tg_deleted_trip() IS 'Delete a trip and merge its previous and next stationary trips into one. Any trip deletion results in the subsequent deletion of its triplegs.';

DROP TRIGGER IF EXISTS trg_deleted_trip ON apiv2.trips_inf;

CREATE TRIGGER trg_deleted_trip
  BEFORE DELETE
  ON apiv2.trips_inf
  FOR EACH ROW
  WHEN ((old.type_of_trip = 1))
  EXECUTE PROCEDURE apiv2.tg_deleted_trip();

CREATE OR REPLACE FUNCTION apiv2.tg_deleted_trip_after()
  RETURNS trigger AS
$BODY$ 
DECLARE
prev_trip_id integer;
next_trip_id integer; 
BEGIN 
	DELETE FROM apiv2.triplegs_inf where trip_id = OLD.trip_id;
  return OLD; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.tg_deleted_trip_after() IS 'DELETES THE TRIPLEGS BELONGING TO THE DELETED TRIP';

DROP TRIGGER IF EXISTS trg_deleted_trip_after ON apiv2.trips_inf;

CREATE TRIGGER trg_deleted_trip_after
  AFTER DELETE
  ON apiv2.trips_inf
  FOR EACH ROW
  EXECUTE PROCEDURE apiv2.tg_deleted_trip_after();

CREATE OR REPLACE FUNCTION apiv2.tg_inserted_trip()
  RETURNS trigger AS
$BODY$
DECLARE 
prev_trip_id int;
next_trip_id int;
BEGIN  
	
  IF NEW.from_time > NEW.to_time THEN 
    RAISE EXCEPTION 'invalid start time later than end time'; 
  END IF; 

  -- if the updated tripleg is a movement period, then update its neighboring stationary trips 
  IF NEW.type_of_trip = 1 THEN 
  -- changed from and to type condition to account for the updates as well 
	-- previous stationary trip
	prev_trip_id := trip_id from apiv2.trips_inf where user_id = NEW.user_id
		and type_of_trip = 0 and from_time <= NEW.from_time order by to_time desc limit 1;
	-- next stationary trip
	next_trip_id := trip_id from apiv2.trips_inf where user_id= NEW.user_id
		and type_of_trip = 0 and to_time >= NEW.to_time order by from_time asc limit 1;
					
	-- if there is a previous stationary period and the from_time of the updated trip is different from the previous from_time 
	IF prev_trip_id is not null THEN 
		UPDATE apiv2.trips_inf set to_time = NEW.from_time where trip_id = prev_trip_id; 
	END IF;

	-- if there is a next stationary period and the to_time of the updated trip is different from the previous to_time 
	IF next_trip_id is not null THEN 
		UPDATE apiv2.trips_inf set from_time = NEW.to_time, to_time = greatest(to_time, NEW.to_time) where trip_id = next_trip_id;
	END IF;
  END IF; 
  return NEW; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION apiv2.tg_inserted_trip() IS 'UPDATE THE NEIGHBORING PASSIVE TRIPS AFFECTED BY THE UPDATE';

DROP TRIGGER IF EXISTS trg_inserted_trip ON apiv2.trips_inf;

CREATE TRIGGER trg_inserted_trip
  AFTER INSERT
  ON apiv2.trips_inf
  FOR EACH ROW
  WHEN ((new.type_of_trip = 1))
  EXECUTE PROCEDURE apiv2.tg_inserted_trip();


CREATE OR REPLACE FUNCTION apiv2.tg_updated_trip_before()
  RETURNS trigger AS
$BODY$
DECLARE 
prev_trip_id int;
next_trip_id int;
BEGIN 

  IF NEW.from_time > NEW.to_time THEN 
    RAISE EXCEPTION 'invalid start time later than end time'; 
  END IF; 

  -- if the updated tripleg is a movement period, then update its neighboring stationary trips 
  IF NEW.type_of_trip = 1 THEN 
	-- previous stationary trip
	prev_trip_id := trip_id from apiv2.trips_inf where user_id = NEW.user_id
		and type_of_trip = 0 and to_time <= OLD.from_time order by to_time desc limit 1;
	-- next stationary trip
	next_trip_id := trip_id from apiv2.trips_inf where user_id= NEW.user_id
		and type_of_trip = 0 and from_time >= OLD.to_time order by from_time asc limit 1;
			
	-- if there is a previous stationary period and the from_time of the updated trip is different from the previous from_time 
	IF prev_trip_id is not null AND NEW.from_time <> OLD.from_time THEN 
		UPDATE apiv2.trips_inf set to_time = NEW.from_time where trip_id = prev_trip_id; 
	END IF;

	-- if there is a next stationary period and the to_time of the updated trip is different from the previous to_time 
	IF next_trip_id is not null AND NEW.to_time <> OLD.to_time THEN 
		UPDATE apiv2.trips_inf set from_time = NEW.to_time, to_time = greatest(to_time, NEW.to_time) where trip_id = next_trip_id;
	END IF;
	
  END IF; 
  return NEW; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION apiv2.tg_updated_trip_before() IS 'UPDATES THE ADJACENT PASSIVE TRIPS TO MAINTAIN TEMPORAL INTEGRITY';

DROP TRIGGER IF EXISTS trg_updated_trip ON apiv2.trips_inf;

CREATE TRIGGER trg_updated_trip
  BEFORE UPDATE
  ON apiv2.trips_inf
  FOR EACH ROW
  WHEN ((new.type_of_trip = 1))
  EXECUTE PROCEDURE apiv2.tg_updated_trip_before();


CREATE OR REPLACE FUNCTION apiv2.tg_updated_trip_after()
  RETURNS trigger AS
$BODY$
DECLARE 
prev_trip_id int;
next_trip_id int;
BEGIN 

  IF NEW.from_time > NEW.to_time THEN 
    RAISE EXCEPTION 'invalid start time later than end time'; 
  END IF; 

	IF NEW.from_time<>OLD.from_time AND NEW.to_time<>OLD.to_time THEN
		update apiv2.triplegs_inf set from_time = NEW.from_time, to_time = NEW.to_time where tripleg_id = (select tripleg_id from apiv2.triplegs_inf where trip_id = NEW.trip_id order by from_time, to_time asc limit 1);
	ELSE
	
		IF NEW.from_time <> OLD.from_time THEN 
		update apiv2.triplegs_inf set from_time = NEW.from_time where tripleg_id = (select tripleg_id from apiv2.triplegs_inf where trip_id = NEW.trip_id order by from_time, to_time asc limit 1);
		END IF;

		IF NEW.to_time <> OLD.to_time THEN
		update apiv2.triplegs_inf set to_time = NEW.to_time where tripleg_id = (select tripleg_id from apiv2.triplegs_inf where trip_id = NEW.trip_id order by from_time desc, to_time desc limit 1);
		END IF;
	END IF;
  return NEW; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION apiv2.tg_updated_trip_after() IS 'UPDATES THE FIRST AND END TRIPLEGS TO MATCH THE TIME UPDATE';

DROP TRIGGER IF EXISTS trg_updated_trip_after ON apiv2.trips_inf;

CREATE TRIGGER trg_updated_trip_after
  AFTER UPDATE
  ON apiv2.trips_inf
  FOR EACH ROW
  EXECUTE PROCEDURE apiv2.tg_updated_trip_after();


-- TRIPLEGS TRIGGERS

CREATE OR REPLACE FUNCTION apiv2.tg_deleted_tripleg_after()
  RETURNS trigger AS
$BODY$
DECLARE  
prev_tripleg_id int;
next_tripleg_id int;
next_to_time bigint;
prev_from_time bigint; 
BEGIN 
  -- if the updated tripleg is a movement period, then update its neighboring stationary triplegs 
  IF OLD.type_of_tripleg = 1 THEN 
  	
	-- previous stationary tripleg
	prev_tripleg_id := tripleg_id from apiv2.triplegs_inf where trip_id = OLD.trip_id
		and type_of_tripleg = 0 and to_time <= OLD.from_time order by to_time desc limit 1;
	-- next stationary tripleg
	next_tripleg_id := tripleg_id from apiv2.triplegs_inf where trip_id = OLD.trip_id
		and type_of_tripleg = 0 and from_time >= OLD.to_time order by from_time asc limit 1;

	prev_from_time := from_time from apiv2.triplegs_inf where tripleg_id = prev_tripleg_id;
	next_to_time := to_time from apiv2.triplegs_inf where tripleg_id = next_tripleg_id;
	
	-- if there is no previous tripleg, then a special action for the first tripleg of the trip has to be taken - update the from_time of the current trip 
	IF prev_tripleg_id is null THEN 
		DELETE FROM apiv2.triplegs_inf where tripleg_id = next_tripleg_id; 
		UPDATE apiv2.trips_inf set from_time = next_to_time where trip_id = OLD.trip_id; 
	END IF;

	-- if there is no next tripleg, then a special action for the last tripleg of the trip has to be taken - update the to_time of the current trip 
	IF next_tripleg_id is null THEN 
		DELETE FROM apiv2.triplegs_inf where tripleg_id = prev_tripleg_id;
		UPDATE apiv2.trips_inf set to_time = OLD.from_time where trip_id = OLD.trip_id; 
	END IF;

	IF prev_tripleg_id is not null and next_tripleg_id is not null THEN  
	DELETE FROM apiv2.triplegs_inf where tripleg_id = next_tripleg_id; 
		UPDATE apiv2.triplegs_inf set to_time = next_to_time where tripleg_id = prev_tripleg_id;  
	END IF;
	
  END IF; 
  return OLD; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION apiv2.tg_deleted_tripleg_after() IS 'DELETE AND / OR UPDATE THE NON MOVEMENT PERIOD NEIGHBORING THE DELETED TRIPLEG';

DROP TRIGGER IF EXISTS trg_deleted_tripleg_after ON apiv2.triplegs_inf;

CREATE TRIGGER trg_deleted_tripleg_after
  AFTER DELETE
  ON apiv2.triplegs_inf
  FOR EACH ROW
  WHEN ((old.type_of_tripleg = 1))
  EXECUTE PROCEDURE apiv2.tg_deleted_tripleg_after();


CREATE OR REPLACE FUNCTION apiv2.tg_deleted_tripleg_before()
  RETURNS trigger AS
$BODY$
DECLARE   
number_of_triplegs_remaining_in_trip int;
BEGIN 
  -- if the updated tripleg is a movement period 
  IF OLD.type_of_tripleg = 1 THEN   
	number_of_triplegs_remaining_in_trip:= count(*) from apiv2.triplegs_inf where trip_id = (select trip_id from apiv2.trips_inf where trip_id = OLD.trip_id);  
	IF number_of_triplegs_remaining_in_trip = 1 THEN 
	RAISE EXCEPTION 'cannot delete the only tripleg in the trip';
	END IF; 
	
  END IF; 
  return OLD; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION apiv2.tg_deleted_tripleg_before() IS 'CHECK IF THE TRIPLEG THAT IS MEANT TO BE DELETED IS NOT THE ONLY TRIPLEG IN THE TRIP';

DROP TRIGGER IF EXISTS trg_deleted_tripleg_before on apiv2.triplegs_inf;

CREATE TRIGGER trg_deleted_tripleg_before
  BEFORE DELETE
  ON apiv2.triplegs_inf
  FOR EACH ROW
  WHEN ((old.type_of_tripleg = 1))
  EXECUTE PROCEDURE apiv2.tg_deleted_tripleg_before();


CREATE OR REPLACE FUNCTION apiv2.tg_inserted_tripleg()
  RETURNS trigger AS
$BODY$
DECLARE 
trip_id bigint; 
user_id int;
number_of_locations int;
safe_to_check boolean;
BEGIN 
	number_of_locations := count(*) from raw_data.location_table l where l.user_id = NEW.user_id and time_ between NEW.from_time and NEW.to_time and accuracy_<= 50;
	trip_id := t.trip_id from apiv2.trips_inf t where t.trip_id = NEW.trip_id; 
	user_id := id from raw_data.user_table u where u.id = NEW.user_id;
	safe_to_check := ((type_of_trip=1) and NEW.type_of_tripleg = 1) from apiv2.trips_inf t where t.trip_id = NEW.trip_id;
	-- this could be obtained via a trigger but it causes problems on deletions due to the order of the trigger cascade drop
  IF trip_id IS NULL THEN 
    RAISE EXCEPTION 'trip_id has to reference a valid key'; 
  END IF; 

    IF user_id IS NULL THEN 
    RAISE EXCEPTION 'trip_id has to reference a valid key'; 
  END IF; 


    IF number_of_locations<2 AND safe_to_check  THEN  
    RAISE EXCEPTION 'insufficient number of locations to form a tripleg'; 
    END IF;
    
  return NEW; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION apiv2.tg_inserted_tripleg() IS '
Check that the inserted tripleg references a valid trip_id and a valid user_id 
';

DROP TRIGGER IF EXISTS trg_inserted_tripleg ON apiv2.triplegs_inf; 

CREATE TRIGGER trg_inserted_tripleg
  BEFORE INSERT
  ON apiv2.triplegs_inf
  FOR EACH ROW
  EXECUTE PROCEDURE apiv2.tg_inserted_tripleg();


CREATE OR REPLACE FUNCTION apiv2.tg_updated_tripleg()
  RETURNS trigger AS
$BODY$
DECLARE 
trip_from_time bigint; 
trip_to_time bigint;
prev_tripleg_id int;
next_tripleg_id int;
number_of_locations_within_update int;
trip_type int;
BEGIN 
	trip_from_time := from_time from apiv2.trips_inf where trip_id = NEW.trip_id;
	trip_to_time := to_time from apiv2.trips_inf where trip_id = NEW.trip_id;
	trip_type := type_of_trip from apiv2.trips_inf where trip_id = NEW.trip_id; 
	number_of_locations_within_update := count(id) from raw_data.location_table where user_id = NEW.user_id and time_ between NEW.from_time and NEW.to_time and accuracy_<50; 		

  IF NEW.from_time < trip_from_time THEN 
    RAISE EXCEPTION 'start time of tripleg has to be within the current trip'; 
  END IF; 

  IF NEW.to_time > trip_to_time THEN 
    RAISE EXCEPTION 'end time of tripleg has to be within the current trip'; 
  END IF; 

  -- if the updated tripleg is a movement period, then update its neighboring stationary triplegs 
  IF NEW.type_of_tripleg = 1 AND (NEW.to_time <> OLD.to_time or NEW.from_time<>OLD.from_time) AND trip_type = 1 THEN 
 
	IF number_of_locations_within_update<2 THEN
	RAISE EXCEPTION 'the updated period does not contain enough locations to form a tripleg, %, %---->%', number_of_locations_within_update, OLD, NEW;
	END IF;
	-- previous stationary tripleg
	prev_tripleg_id := tripleg_id from apiv2.triplegs_inf where trip_id = NEW.trip_id
		and type_of_tripleg = 0 and to_time <= greatest(OLD.from_time, NEW.from_time) order by to_time desc limit 1;
	-- next stationary tripleg
	next_tripleg_id := tripleg_id from apiv2.triplegs_inf where trip_id = NEW.trip_id
		and type_of_tripleg = 0 and from_time >= least(OLD.to_time, NEW.to_time) order by from_time asc limit 1;
 
	IF prev_tripleg_id IS NULL AND NEW.from_time <> OLD.from_time AND trip_from_time<>NEW.from_time THEN 
	RAISE EXCEPTION 'the start period of the first tripleg cannot be updated';
	END IF; 

	IF next_tripleg_id IS NULL AND NEW.to_time <> OLD.to_time AND trip_to_time<>NEW.to_time THEN
	RAISE EXCEPTION 'the end period of the last tripleg cannot be updated'; 
	END IF;
	
	-- if there is a previous stationary period and the from_time of the updated tripleg is different from the previous from_time 
	IF prev_tripleg_id is not null AND NEW.from_time <> OLD.from_time THEN 
		UPDATE apiv2.triplegs_inf set to_time = NEW.from_time where tripleg_id = prev_tripleg_id;
	END IF;

	-- if there is a next stationary period and the to_time of the updated tripleg is different from the previous to_time 
	IF next_tripleg_id is not null AND NEW.to_time <> OLD.to_time THEN 
		UPDATE apiv2.triplegs_inf set from_time = NEW.to_time where tripleg_id = next_tripleg_id;
	END IF;
	
  END IF; 
  return NEW; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION apiv2.tg_updated_tripleg()
  OWNER TO postgres;
COMMENT ON FUNCTION apiv2.tg_updated_tripleg() IS '
Check that the updates of a tripleg only occusr within the time frame of the trip and does not overflow to neighboring trips. 
Also assures time period consistency for stationary period triplegs';

DROP TRIGGER IF EXISTS trg_updated_tripleg ON apiv2.triplegs_inf;

CREATE TRIGGER trg_updated_tripleg
  AFTER UPDATE
  ON apiv2.triplegs_inf
  FOR EACH ROW
  EXECUTE PROCEDURE apiv2.tg_updated_tripleg();

