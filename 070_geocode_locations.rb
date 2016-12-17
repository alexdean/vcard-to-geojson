# https://console.developers.google.com/apis/credentials/key/121?project=api-project-5689355642


'https://maps.googleapis.com/maps/api/geocode/json?address=Wessington+Springs,57382,USA&key=AIzaSyBuVwkqslbRGUHs1djLjYa5b5q0EST23pI'
'https://maps.googleapis.com/maps/api/geocode/json?address=Ormeau,QLD+4208,Australia&key=AIzaSyBuVwkqslbRGUHs1djLjYa5b5q0EST23pI'

require 'rest-client'
require_relative 'lib/db'

db = DB.new
log = Logger.new($stdout)
log.level = Logger::DEBUG

GOOGLE_API_KEY = 'AIzaSyBuVwkqslbRGUHs1djLjYa5b5q0EST23pI'

'select * from addresses where location IS NULL'

