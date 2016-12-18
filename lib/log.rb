require 'logger'
require_relative 'config'

class Log
  def self.factory(log_level: 'WARN')
    log = Logger.new($stdout)
    log.level = case log_level
                when 'DEBUG'
                  then Logger::DEBUG
                when 'INFO'
                  then Logger::INFO
                when 'WARN'
                  then Logger::WARN
                when 'ERROR'
                  then Logger::ERROR
                else
                  raise "Invalid log level '#{log_level}' (#{log_level.class})"
                end
    log
  end
end
