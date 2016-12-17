require 'pathname'
require 'uri'
require 'rest-client'
require 'json'
require_relative 'lib/db'

this_dir = Pathname.new(File.dirname(File.realpath(__FILE__)))
credentials = JSON.parse(File.read(this_dir.join('credentials.json')))
google_api_key = credentials.dig('google', 'geocoding', 'apikey')

db = DB.new
log = Logger.new($stdout)
log.level = Logger::DEBUG

RestClient.log = log

db.exec('select * from locations where geom IS NULL').each do |row|
  # seems to be enough for google geocoder
  address_parts = [
    row['city'],
    row['postal_code'],
    row['country']
  ]

  address_string = address_parts
                     .map{|s| s.strip.gsub(/[^[[:print:]]]/, '') }
                     .join(',')

  log.info address_string
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
    puts "#{e.message} (e.class)"
    puts e.backtrace.join("\n")
    next
  end
end
