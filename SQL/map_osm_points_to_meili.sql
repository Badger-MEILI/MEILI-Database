delete from apiv2.pois;
delete from apiv2.poi_transportation;

insert into apiv2.pois(type_, name_, lat_, lon_, osm_id, geom)

select 
'shop'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
shop is not null 

union all 

select 
'tourism'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
tourism is not null 

union all 

select 
'service'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
service is not null 

union all 

select 
'religion'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
religion is not null 

union all 

select type, name, lon as lat, lat as lon, osm_id, st_transform as geom from (
select 
'shop'::text as type , name, st_x(st_transform(way,4326)) as lat, 
st_y(st_transform(way,4326)) as lon, osm_id, st_transform(way,4326)from planet_osm_point 
where 
shop is not null 

union all 

select 
'tourism'::text as type , name, st_x(st_transform(way,4326)) as lat, 
st_y(st_transform(way,4326)) as lon, osm_id, st_transform(way,4326)from planet_osm_point 
where 
tourism is not null 

union all 

select 
'service'::text as type , name, st_x(st_transform(way,4326)) as lat, 
st_y(st_transform(way,4326)) as lon, osm_id, st_transform(way,4326)from planet_osm_point 
where 
service is not null 

union all 

select 
'religion'::text as type , name, st_x(st_transform(way,4326)) as lat, 
st_y(st_transform(way,4326)) as lon, osm_id, st_transform(way,4326)from planet_osm_point 
where 
religion is not null 

union all

select 
'poi'::text as type , name, st_x(st_transform(way,4326)) as lat, 
st_y(st_transform(way,4326)) as lon, osm_id, st_transform(way,4326)from planet_osm_point 
where 
poi is not null 

union all 

select 
'shop'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
shop is not null 

union all 

select 
'tourism'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
tourism is not null 

union all 

select 
'service'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
service is not null 

union all 

select 
'religion'::text as type , name, st_x(st_transform(st_centroid(way),4326)) as lat, 
st_y(st_transform(st_centroid(way),4326)) as lon, osm_id, st_transform(st_centroid(way),4326)from planet_osm_polygon
where 
religion is not null ) foo;

insert into apiv2.poi_transportation(osm_id, type_, name_, lat_, lon_, geom)

select osm_id, type, name,
st_y(st_transform(way, 4326)) as latitude,
st_x(st_transform(way, 4326)) as longitude, 
st_transform(way, 4326) as geom

	FROM (
	select osm_id, string_to_array(regexp_replace(ref, '[ \t\n\r]*','','g'), ','::text) as lines, ref as osm_unparsed_lines, way, 'bus station' as type, name from planet_osm_point
	where highway='bus_stop'
	or amenity ='bus_station'
	or public_transport = 'bus_stop'
	 
	union all 

	select osm_id, string_to_array(regexp_replace(ref, '[ \t\n\r]*','','g'), ','::text), ref, way, 'tram', name as type from planet_osm_point
	where railway ='tram_stop' 
	 
	union all 

	select osm_id, string_to_array(regexp_replace(ref, '[ \t\n\r]*','','g'), ','::text), ref, way, 'subway', name as type from planet_osm_point
	where railway ='subway_entrance' 

	union all 

	select osm_id, string_to_array(regexp_replace(ref, '[ \t\n\r]*','','g'), ','::text), ref, way, 'train', name as type from planet_osm_point
	where railway ='halts' 
	or railway='station'

	union all 

	select osm_id, string_to_array(regexp_replace(ref, '[ \t\n\r]*','','g'), ','::text), ref, way, 'boat', name as type from planet_osm_point
	where amenity ='ferry_terminal' 
	) 
	as stations
