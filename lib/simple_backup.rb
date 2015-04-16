require 'simple_backup/utils'
require 'simple_backup/version'
require 'simple_backup/logger'
require 'simple_backup/dsl'
require 'simple_backup/storage'
require 'simple_backup/engine'
require 'simple_backup/mailer'
require 'simple_backup/exception'

module SimpleBackup
  TIMESTAMP = Time.new.strftime('%Y%m%d%H%M%S')
  @@status = :failed
  @@logger = Logger.instance

  def self.status
    @@status
  end

  def self.run(&block)
    @@logger.info "Backup #{TIMESTAMP} started"

    dsl = DSL.new

    @@logger.scope_start :info, "Configuration"
    dsl.instance_eval(&block)
    dsl.prepare
    @@logger.scope_end

    dsl.run
    dsl.cleanup
    @@status = :succeed

    @@logger.info "Backup #{TIMESTAMP} finished"
  rescue StandardError => e
    self.handle_exception(e)
  ensure
    dsl.notify if dsl
    @@logger.info "Notifications for backup #{TIMESTAMP} finished"
  end

  def self.handle_exception(e)
    @@logger.error "#{e.class} => #{e.message}"
    @@logger.error "Backup #{TIMESTAMP} failed"

    STDERR.puts "Error @ #{Time.new.strftime('%Y-%m-%dT%H:%M:%S')}"
    STDERR.puts "#{e.inspect}"
    STDERR.puts e.backtrace
  end
end
