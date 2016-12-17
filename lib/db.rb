require 'pg'
require 'logger'

class DB

  attr_reader :conn, :db_name

  def initialize(db_name:nil, log:nil)
    @db_name = db_name || 'christmas_2016'
    @log = log || Logger.new('/dev/null')
    @log.progname = 'db'
    verify
    @conn = PG.connect(dbname: @db_name)
    @conn.type_map_for_results = PG::BasicTypeMapForResults.new(@conn)
  end

  # spatial reference id to use for geometry types and spatial queries
  # EPSG4326 = WGS84
  def srid
    4326
  end

  def verify
    result = PG.connect.exec "select count(*) as db_exists from pg_database where datname = '#{db_name}'"
    if result[0]['db_exists'] == '0'
      `createdb #{db_name}`
      `echo 'create extension postgis' | psql #{db_name}`
      @log.info "Created database #{db_name}."
    end
  end

  # TODO there's a proxy/delegate module in ruby. can't remember what it's called, though.
  def exec(sql)
    conn.exec sql
  end
  def prepare(*args)
    conn.prepare *args
  end
  def exec_prepared(*args)
    conn.exec_prepared *args
  end
  def exec_params(*args)
    conn.exec_params *args
  end

  def table_exists?(table_name)
    result = conn.exec "select count(*) as table_exists from pg_tables where tablename = '#{table_name}'"
    result[0]['table_exists'] == 0 ? false : true
  end
  def column_exists?(table_name, column_name)
    result = conn.exec <<-EOF
      SELECT count(*) as column_exists
      FROM information_schema.columns
      WHERE
        table_name = '#{table_name}'
        AND column_name = '#{column_name}'
    EOF
    result[0]['column_exists'] == 0 ? false : true
  end

end
