require_relative 'lib/db'
require 'logger'

log = Logger.new($stdout)
log.level = Logger::DEBUG

db = DB.new

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

  db.exec "SELECT AddGeometryColumn('locations', 'geom', #{db.srid}, 'POINT', 2, false)"
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
end
