require 'vcard'
require_relative '../lib/db'
require_relative '../lib/log'

input_filename = ARGV[0]
log_level = ARGV[2]

$db = DB.new(log_level: log_level)
$log = Log.factory(log_level: log_level)

$db.exec 'truncate table people'

def location_id_for(city, postal_code, region, country)
  id = $db.exec_params(
    'SELECT id FROM locations WHERE postal_code=$1::varchar AND country=$2::varchar',
    [postal_code, country]
  ).first&.dig('id')

  if !id
    sql = <<-EOF
      INSERT INTO locations (
        city,
        postal_code,
        region,
        country
      ) values (
        $1::varchar,
        $2::varchar,
        $3::varchar,
        $4::varchar
      )
      RETURNING id
    EOF
    id = $db.exec_params(sql, [city, postal_code, region, country]).first['id']
  end

  id
end

if !File.exist?(input_filename)
  raise "Input file #{input_filename} does not exist."
end

Vcard::Vcard.decode(File.read(input_filename)).each do |card|
  address = card.address
  if address.nil?
    $log.error "nil address: #{card.name.fullname}"
    next
  end
  $log.debug "Imported '#{card.name.fullname}' from vcard."

  city = address.locality.strip.gsub(/,$/, '')
  country = address.country == "" ? "USA" : address.country
  location_id = location_id_for(city, address.postalcode, address.region, country)

  $db.exec_params(
    'INSERT INTO people (name, location_id) values ($1::varchar, $2::integer)',
    [card.name.fullname, location_id]
  )
end


