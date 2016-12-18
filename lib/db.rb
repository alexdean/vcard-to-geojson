require 'pg'
require 'forwardable'
require_relative 'config'

class DB
  extend Forwardable
  attr_reader :conn, :db_name, :srid

  def_delegators :@conn, :exec, :prepare, :exec_prepared, :exec_params

  def initialize(db_name: nil, srid: 4326, log_level: 'WARN')
    @db_name = db_name || Config.db_name

    # spatial reference id to use for geometry types and spatial queries
    # EPSG 4326 = WGS84
    @srid = srid

    @log = Log.factory(log_level: log_level)

    create_database_if_missing

    @conn = PG.connect(dbname: @db_name)
    @conn.type_map_for_results = PG::BasicTypeMapForResults.new(@conn)
  end

  # create the requested database if it doesn't exist
  def create_database_if_missing
    result = PG.connect.exec "select count(*) as db_exists from pg_database where datname = '#{db_name}'"
    if result[0]['db_exists'] == '0'
      `createdb #{db_name}`
      `echo 'create extension postgis' | psql #{db_name}`
      @log.warn "Created database #{db_name}."
    end
  end

  # does the specified table exist in the current database?
  #
  # @param [String] table_name
  # @return [bool]
  def table_exists?(table_name)
    sql = 'select count(*) as table_exists from pg_tables where tablename = $1::varchar'
    result = conn.exec_params(sql, [table_name])
    result[0]['table_exists'] == 0 ? false : true
  end

  # does the specified column exist in the named table?
  #
  # @param [String] table_name
  # @param [String] column_name
  # @return [bool]
  def column_exists?(table_name, column_name)
    sql = <<-EOF
      SELECT count(*) as column_exists
      FROM information_schema.columns
      WHERE
        table_name = $1::varchar
        AND column_name = $2::varchar
    EOF
    result = conn.exec_params(sql, [table_name, column_name])
    result[0]['column_exists'] == 0 ? false : true
  end
end
