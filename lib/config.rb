require 'ostruct'
require 'yaml'
require 'pathname'

this_dir = Pathname.new(File.dirname(__FILE__))

Config = OpenStruct.new(
  YAML.load_file(this_dir.join('../config.yml'))
)
