require_relative 'lib/db'

# needed to re-install gdal to get pg driver.
# brew install gdal --with-postgresql

db = DB.new

`ogr2ogr -f GeoJSON out/addresses.geojson \
  PG:"host=localhost dbname=#{db.db_name}" \
  -sql "select l.geom, count(*) as addresses from locations l inner join people p ON (l.id = p.location_id) where geom is not null group by l.geom"`
