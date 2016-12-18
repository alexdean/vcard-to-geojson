require 'optparse'
require_relative 'lib/config'

valid_levels = %w(DEBUG INFO WARN ERROR)

options = {log_level: 'INFO'}

opt_parser = OptionParser.new do |opts|
  opts.banner = <<-EOF.gsub(/^ {4}/, '')
    Usage: #{__FILE__} [options]
    Read addresses in a VCARD and produce a GeoJSON file summarizing their locations.

    See README.md for information on required configuration values.

  EOF

  opts.on("-i INPUT", "--input=INPUT", "A vcard containing addresses.") do |o|
    options[:input] = o
  end

  opts.on("-o OUTPUT", "--output=OUTPUT", "The GeoJSON file to create.") do |o|
    options[:output] = o
  end

  opts.on('-l LEVEL', '--level=LEVEL', "Output level. Valid values: #{valid_levels.join(', ')}") do |o|
    options[:log_level] = o
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end

opt_parser.parse!(ARGV)

errors = []
if !options[:input]
  errors << '--input is required'
elsif !File.exist?(options[:input])
  errors << "input file '#{options[:input]}' does not exist."
end

if !options[:output]
  errors << '--output is required'
end

if !valid_levels.include?(options[:log_level])
  errors << "--level must be one of: #{valid_levels.inspect}"
end

if errors.size > 0
  puts "ERRORS:"
  puts '  ' + errors.join("\n  ")
  puts
  puts "Use --help for more information."
  exit 1
end

options.each {|key, value| Config.send(:"#{key}=", value) }

require_relative 'lib/log'
log = Log.factory(log_level: Config.log_level)

Dir['process/*.rb'].each do |file|
  log.warn "Running #{file}."
  command = "bundle exec ruby #{file} #{Config.input} #{Config.output} #{Config.log_level}"
  log.debug "   #{command}"
  system command
  if $? != 0
    exit
  end
end

log.info 'Process complete.'
