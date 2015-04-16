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

  class DSL
    @@logger = Logger.instance

    def initialize
      @storage = Storage.new
    end

    def prepare
      if @apps_block
        @apps = Engine::Apps.new
        @apps.storage = @storage
        @apps.instance_eval(&@apps_block)
      end

      if @mysql_block
        @mysql = Engine::MySQL.new
        @mysql.storage = @storage
        @mysql.instance_eval(&@mysql_block)
      end
    end

    def run
      usage = Utils::Disk::usage
      @@logger.error "Disk high usage treshold exceeded #{usage[:high_usage]}" if usage[:high_usage_exceeded]

      @@logger.scope_start :info, "Backup job"
      @apps.backup if @apps
      @mysql.backup if @mysql
      @@logger.scope_end
    end

    def cleanup
      @@logger.scope_start :info, "Cleanup job"
      @apps.cleanup if @apps
      @mysql.cleanup if @mysql
      @@logger.scope_end
    end

    def notify
      @mailer.send if @mailer
    rescue StandardError => e
      SimpleBackup.handle_exception(e)
    end

    def sources
      sources = {}
      sources[:apps] = @apps.sources if @apps
      sources[:mysql] = @mysql.sources if @mysql

      sources
    end

    def log_level(level)
      @@logger.level = level
    end

    def backup_dir(dir)
      @storage.dir = dir
    end

    def high_usage_treshold(value)
      @@logger.info "Setting high_usage_treshold to #{value}"
      Utils::Disk.high_usage_treshold = value
    end

    def check_disk_path(path)
      @@logger.info "Adding disk path '#{path}' to usage check"
      Utils::Disk.add_path(path)
    end

    def apps(&block)
      @apps_block = block
    end

    def mysql(&block)
      @mysql_block = block
    end

    def mailer(&block)
      @mailer = Mailer.new(self, @storage)
      @mailer.instance_eval(&block)
    end
  end
end

