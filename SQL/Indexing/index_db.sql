CREATE INDEX location_table_time_index 
ON raw_data.location_table(time_); 

CREATE INDEX poi_transportation_geometry_index
ON apiv2.poi_transportation USING GIST (geom); 

CREATE INDEX pois_geometry_index
ON apiv2.pois USING GIST (geom); 

CREATE INDEX pois_user_id_index
ON apiv2.pois(user_id); 

CREATE INDEX triplegs_inf_from_time_index
ON apiv2.triplegs_inf(from_time);

CREATE INDEX triplegs_inf_to_time_index
ON apiv2.triplegs_inf(to_time);

CREATE INDEX trips_from_time_index 
ON apiv2.trips_inf(from_time);

CREATE INDEX trips_to_time_index
ON apiv2.trips_inf(to_time); 