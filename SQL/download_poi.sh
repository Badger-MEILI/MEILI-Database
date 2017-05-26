echo "Downloading bus stops"

wget -O bus_stops.osm "http://overpass-api.de/api/interpreter?data=node[\"amenity\"=\"bus_station\"]($1,$2,$3,$4);out body;node[\"highway\"=\"bus_stop\"]($1,$2,$3,$4);out body;node[\"public_transport\"=\"bus_stop\"]($1,$2,$3,$4);out body;"

echo "Successful... Downloading bus stops"

sleep 1

echo "Downloading tram stops"

wget -O tram_stops.osm "http://overpass-api.de/api/interpreter?data=node[\"railway\"=\"tram_stop\"]($1,$2,$3,$4);out body;" 

echo "Successful... Downloading tram stops"

sleep 1

echo "Downloading subway stops"

wget -O subway_stops.osm "http://overpass-api.de/api/interpreter?data=node[\"railway\"=\"subway_entrance\"]($1,$2,$3,$4);out body;" 

echo "Successful... Downloading subway stops"

sleep 1

echo "Downloading train stops"

wget -O train_stops.osm "http://overpass-api.de/api/interpreter?data=node[\"railway\"=\"station\"]($1,$2,$3,$4);out body;node[\"railway\"=\"halt\"]($1,$2,$3,$4);out body;" 

echo "Successful... Downloading train stops"

sleep 1

echo "Downloading boat stops"

wget -O ferry_stops.osm "http://overpass-api.de/api/interpreter?data=node[\"amenity\"=\"ferry_terminal\"]($1,$2,$3,$4);out body;" 

echo "Successful... Downloading boat stops"

sleep 1

echo "Downloading parking places"

wget -O parking_places.osm "http://overpass-api.de/api/interpreter?data=node[\"amenity\"=\"parking\"]($1,$2,$3,$4);out body;" 

echo "Successful... Downloading parking places"

echo "Successful... Download finished" 

psql -h $7 -U $6 $5 -c 'create extension if not exists hstore; create extension if not exists postgis;'

sleep 1

echo "Downloading POIS => shops"

wget -O poi_shops.osm "http://overpass-api.de/api/interpreter?data=node[\"shop\"]($1,$2,$3,$4);out body; way[\"shop\"]($1,$2,$3,$4);(._;>;);out body;"

echo "Finished downloading POIS => shops"

sleep 1

echo "Downloading POIS => tourism"

wget -O poi_tourism.osm "http://overpass-api.de/api/interpreter?data=node[\"tourism\"]($1,$2,$3,$4);out body; way[\"tourism\"]($1,$2,$3,$4);(._;>;);out body;"

echo "Finished downloading POIS => tourism"

sleep 1

echo "Downloading POIS => service"

wget -O poi_service.osm "http://overpass-api.de/api/interpreter?data=node[\"service\"]($1,$2,$3,$4);out body; way[\"service\"]($1,$2,$3,$4);(._;>;);out body;"

echo "Finished downloading POIS => service"

sleep 1

echo "Downloading POIS => religion"

wget -O poi_religion.osm "http://overpass-api.de/api/interpreter?data=node[\"religion\"]($1,$2,$3,$4);out body; way[\"religion\"]($1,$2,$3,$4);(._;>;);out body;"

echo "Finished downloading POIS => religion"

osm2pgsql -c -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse poi_shops.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse poi_tourism.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse poi_service.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse poi_religion.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse tram_stops.osm

osm2pgsql --append -d $5 -U $6 -H $7  --cache-strategy sparse --cache 100 bus_stops.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse subway_stops.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse train_stops.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse ferry_stops.osm

osm2pgsql --append -d $5 -U $6 -H $7 --cache 100  --cache-strategy sparse parking_places.osm

psql -d $5 -h $7 -U $6 -a -f map_osm_points_to_meili.sql

rm *.osm
