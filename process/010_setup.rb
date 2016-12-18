require_relative '../lib/db'
require_relative '../lib/log'

log_level = ARGV[2]
db = DB.new(log_level: log_level)
log = Log.factory(log_level: log_level)

if !db.table_exists?('locations')
  sql = <<-EOF
    CREATE TABLE locations (
      id serial primary key,
      city varchar(255),
      postal_code varchar(10),
      region varchar(50),
      country varchar(50),
      unique(postal_code, country)
    )
  EOF
  db.exec sql

  db.exec_params(
    "SELECT AddGeometryColumn('locations', 'geom', $1::integer, 'POINT', 2, false)",
    [db.srid]
  )
  log.info 'Created table: locations'
end

if !db.table_exists?('people')
  sql = <<-EOF
    CREATE TABLE people (
      id serial primary key,
      name varchar(255),
      location_id int
    )
  EOF
  db.exec sql

  log.info 'Created table: people'
end
