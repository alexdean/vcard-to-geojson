require 'pathname'
require 'uri'
require 'rest-client'
require 'json'
require_relative '../lib/db'
require_relative '../lib/log'

google_api_key = Config.google_api_key

log_level = ARGV[2]
db = DB.new(log_level: log_level)
log = Log.factory(log_level: log_level)

RestClient.log = log if log.level < Logger::INFO

db.exec('select * from locations where geom IS NULL').each do |row|
  # seems to be enough for google geocoder
  address_parts = [
    row['city'],
    row['postal_code'],
    row['country']
  ]

  address_string = address_parts
                     .map{|s| s.strip.gsub(/[^[[:print:]]]/, '') } # remove unprintables
                     .join(',')

  log.debug "Geocoding #{address_string}"
  begin
    response = RestClient.get('https://maps.googleapis.com/maps/api/geocode/json',
      params: {
        address: address_string, key: google_api_key
      }
    )
    json = JSON.parse(response.body)

    lat = json['results'].first['geometry']['location']['lat']
    lng = json['results'].first['geometry']['location']['lng']
    sql = <<-EOF
      UPDATE locations
      SET geom = ST_SetSRID(ST_MakePoint($1::float, $2::float), $3::integer)
      WHERE id = $4::integer
    EOF
    db.exec_params(sql, [lng, lat, db.srid, row['id']])
  rescue => e
    log.error "#{e.message} (e.class)"
    log.error e.backtrace.join("\n")
    next
  end
end
