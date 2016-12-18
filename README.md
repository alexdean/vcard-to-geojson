Geocode the addresses in a vcard file and output a GeoJSON result.

Geocoding is intentionally done only to the level of postal codes. This is
sufficient for thematic mapping, without the risk of disclosure of individual
addresses.

## Requirements

  1. [postgres](https://www.postgresql.org/) + [postgis](http://postgis.net/)
  1. a google geocoding api key. `config.yml.example` has information on how
     to obtain a key.

### On OSX (using homebrew)

```
brew install gdal --with-postgresql
brew install postgis
```

## Usage

```
$ cd vcard-to-geojson
$ cp config.yml.example config.yml
$ vi config.yml # add the needed data
$ bundle
$ bundle exec ruby main.rb --help
```

## Options

```
$ bundle exec ruby main.rb --help
Usage: main.rb [options]
Read addresses in a VCARD and produce a GeoJSON file summarizing their locations.

See README.md for information on required configuration values.

    -i, --input=INPUT                A vcard containing addresses.
    -o, --output=OUTPUT              The GeoJSON file to create.
    -l, --level=LEVEL                Output level. Valid values: DEBUG, INFO, WARN, ERROR
    -h, --help                       Prints this help
```
