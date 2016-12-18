require_relative '../lib/db'
require_relative '../lib/log'


output_filename = ARGV[1]
log_level = ARGV[2]

log = Log.factory(log_level: log_level)

# i needed to re-install gdal to get pg driver.
#   brew install gdal --with-postgresql

db = DB.new(log_level: log_level)

sql = 'select l.geom, count(*) as feature_count from locations l inner join people p ON (l.id = p.location_id) where geom is not null group by l.geom'

command = <<-EOF
ogr2ogr -f GeoJSON #{output_filename} \
  PG:"host=localhost dbname=#{db.db_name}" \
  -sql "#{sql}"
EOF

log.debug command

system command

if $? == 0
  log.info "Created #{output_filename}."
else
  log.error "Failed to create #{output_filename}."
end
