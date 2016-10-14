-- INSERT TEST USER 
INSERT INTO raw_data.user_table VALUES (-1, 'foo@user.com', crypt('foopassword', gen_salt('bf',8)), 'foo_phone', 'foo_os');

-- INSERT TEST GPS POINTS  

INSERT INTO raw_data.location_table(id, user_id, accuracy_, lat_, lon_, time_) VALUES
-- first_trip between 09:20 and 10:00
-- first_trip -> first movement tripleg: walked from  09:20 to 09:25
(-100, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:22:40'::timestamp without time zone)),
(-99, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:23:00'::timestamp without time zone)),
(-98, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:23:50'::timestamp without time zone)),
(-97, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:24:00'::timestamp without time zone)),
(-96, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:25:00'::timestamp without time zone)),
-- first_trip -> first stationary tripleg period: waited for bus between 09:25 and 09:30
(-95, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:28:00'::timestamp without time zone)),
-- first_trip -> last movement tripleg: took the bus between 09:30 and 10:00 
(-94, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:31:00'::timestamp without time zone)),
(-93, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:34:00'::timestamp without time zone)),
(-92, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:39:00'::timestamp without time zone)),
(-91, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:40:00'::timestamp without time zone)),
(-90, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:41:00'::timestamp without time zone)),
(-89, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:42:00'::timestamp without time zone)),
(-88, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 09:55:00'::timestamp without time zone)),
(-87, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone)),
-- first stationary trip period: stayed at home between 10:00 and 12:00
(-86, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 10:20:00'::timestamp without time zone)),
(-85, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 11:00:00'::timestamp without time zone)),
(-84, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 11:30:00'::timestamp without time zone)),
(-83, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone)),
-- second trip: first and only tripleg walked between 12:00 and 12:20
(-82, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:05:00'::timestamp without time zone)),
(-81, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:10:00'::timestamp without time zone)),
(-80, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:15:00'::timestamp without time zone)),
(-719, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone)), 
-- second stationary trip period: stayed at work between 12:20 and 17:00 without any GPS points or triplegs recorded 
-- third trip: first tripleg walked between 17:00 and 17:05
(-79, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone)), 
(-78, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:01:00'::timestamp without time zone)), 
(-77, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:03:00'::timestamp without time zone)), 
(-76, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:05:00'::timestamp without time zone)), 
-- third trip: first stationary tripleg period: waited for the tram between 17:05 and 17:07 without any GPS points recorded 
-- third trip: took the tram between 17:07 and 17:42 
(-75, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:07:00'::timestamp without time zone)), 
(-74, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:17:00'::timestamp without time zone)), 
(-73, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:20:00'::timestamp without time zone)), 
(-72, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:22:00'::timestamp without time zone)), 
(-71, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:30:00'::timestamp without time zone)), 
(-70, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:35:00'::timestamp without time zone)), 
(-69, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:40:00'::timestamp without time zone)), 
(-68, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:47:00'::timestamp without time zone)), 
-- third trip: second stationary tripleg switched to walking between 17:47 and 17:48 
(-67, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:47:30'::timestamp without time zone)), 
-- third trip: third tripleg walked between 17:48 and 18:00
(-66, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone)), 
(-65, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone)), 
-- third stationary trip period: stayed at home between 18:00 and 19:00
(-64, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 18:30:00'::timestamp without time zone)), 
-- fourth and last trip: firs tripleg walked between 19:00 and 19:10 
(-63, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone)), 
(-62, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:05:00'::timestamp without time zone)), 
-- fourth and last trip: first stationary tripleg switched to car between 19:10 and 19:10 
-- fourth and last trip: second and last tripleg: drove car between 19:10 and 19:20 
(-61, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone)), 
(-60, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:11:00'::timestamp without time zone)), 
(-59, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:12:00'::timestamp without time zone)), 
(-58, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:15:00'::timestamp without time zone)), 
(-57, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:17:00'::timestamp without time zone)), 
(-56, -1, 20, 59.2976978204808,18.0005932245796, 1000 * extract (epoch from '2016-09-26 19:20:00'::timestamp without time zone));


-- INSERT TEST TRIPS 

-- first trip between 09:20 and 10:00
insert into apiv2.trips_inf(trip_id, user_id, from_time, to_time, type_of_trip)
VALUES 
-- first trip between 09:20 and 10:00
(-10, -1, 1000 * extract (epoch from '2016-09-26 09:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1),
-- first stationary trip period: stayed at home between 10:00 and 12:00
(-9, -1, 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 0),
-- second trip: between 12:00 and 12:20
(-8, -1, 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1),
-- second stationary trip period: stayed at work between 12:20 and 17:00 without any GPS points or triplegs recorded 
(-7, -1, 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 0),
-- third trip: between 17:00 and 18:00
(-6, -1, 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1),
-- third stationary trip period: stayed at home between 18:00 and 19:00
(-5, -1, 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 0),
-- fourth trip: between 19:00 and 19:20
(-4, -1, 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:20:00'::timestamp without time zone), 1);


-- INSERT TEST TRIPLEGS 
INSERT INTO apiv2.triplegs_inf (tripleg_id, trip_id, user_id, from_time, to_time, type_of_tripleg) 
VALUES
-- first_trip (-10) -> first movement tripleg: walked from  09:20 to 09:25 
(-20, -10, -1, 1000 * extract (epoch from '2016-09-26 09:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 09:25:00'::timestamp without time zone), 1),
-- first_trip (-10) -> first stationary tripleg period: waited for bus between 09:25 and 09:30
(-19, -10, -1, 1000 * extract (epoch from '2016-09-26 09:25:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 09:30:00'::timestamp without time zone), 0),
-- first_trip (-10) -> last movement tripleg: took the bus between 09:30 and 09:40 
(-18, -10, -1, 1000 * extract (epoch from '2016-09-26 09:30:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1),
-- first stationary trip period (-9): stayed at home between 10:00 and 12:00
(-17, -9, -1, 1000 * extract (epoch from '2016-09-26 10:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 1),
-- second trip (-8): first and only tripleg walked between 12:00 and 12:20
(-16, -8, -1, 1000 * extract (epoch from '2016-09-26 12:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1),
-- second stationary trip period (-7): stayed at work between 12:20 and 17:00 without any GPS points or triplegs recorded 
(-15, -7, -1, 1000 * extract (epoch from '2016-09-26 12:20:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 0),
-- third trip (-6): first tripleg walked between 17:00 and 17:05
(-14, -6, -1, 1000 * extract (epoch from '2016-09-26 17:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:05:00'::timestamp without time zone), 1),
-- third trip (-6): first stationary tripleg period: waited for the tram between 17:05 and 17:07 without any GPS points recorded 
(-13, -6, -1, 1000 * extract (epoch from '2016-09-26 17:05:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:07:00'::timestamp without time zone), 0),
-- third trip (-6): took the tram between 17:07 and 17:47
(-12, -6, -1, 1000 * extract (epoch from '2016-09-26 17:07:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:47:00'::timestamp without time zone), 1),
-- third trip (-6): second stationary tripleg switched to walking between 17:47 and 17:48 
(-11, -6, -1, 1000 * extract (epoch from '2016-09-26 17:47:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone), 0),
-- third trip (-6): third tripleg walked between 17:48 and 18:00
(-10, -6, -1, 1000 * extract (epoch from '2016-09-26 17:48:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1),
-- third stationary trip period (-5): stayed at home between 18:00 and 19:00
(-9, -5, -1, 1000 * extract (epoch from '2016-09-26 18:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 1),
-- fourth and last trip (-4): firs tripleg walked between 19:00 and 19:10 
(-8, -4, -1, 1000 * extract (epoch from '2016-09-26 19:00:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 1),
-- fourth and last trip (-4): first stationary tripleg switched to car between 19:10 and 19:10 
(-7, -4, -1, 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 0),
-- fourth and last trip (-4): second and last tripleg: drove car between 19:10 and 19:20 
(-6, -4, -1, 1000 * extract (epoch from '2016-09-26 19:10:00'::timestamp without time zone), 1000 * extract (epoch from '2016-09-26 19:20:00'::timestamp without time zone), 1); 
