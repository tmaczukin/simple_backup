require 'simple_backup/version'
require 'simple_backup/utils'
require 'simple_backup/dsl'
require 'simple_backup/sources'
require 'simple_backup/backends'
require 'simple_backup/engine'

# SimpleBackup module
module SimpleBackup
  attr_writer :logger

  TIMESTAMP = Time.new.strftime('%Y%m%d%H%M%S')

  @@status = :failed

  def self.status
    @@status
  end

  def self.define(&block)
    logger.scope_start :info, "Backup #{TIMESTAMP} started"

    engine = Engine::Engine.new
    dsl = DSL.new(engine)

    logger.scope_start :info, 'Configuration'
    dsl.instance_eval(&block)
    logger.scope_end

    engine.run
    @@status = :succeed

    logger.scope_end :info, "Backup #{TIMESTAMP} finished"
  rescue StandardError => e
    handle_exception(e)
  ensure
    engine.notify if engine
  end

  def self.handle_exception(e)
    logger.error "#{e.class} => #{e.message}"
    logger.error "Backup #{TIMESTAMP} failed"

    STDERR.puts "Error @ #{Time.new.strftime('%Y-%m-%dT%H:%M:%S')}"
    STDERR.puts "#{e.inspect}"
    STDERR.puts e.backtrace
  end

  private

  def self.logger
    Utils::Logger.instance unless @logger
    @logger if @logger
  end
end
