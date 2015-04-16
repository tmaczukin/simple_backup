module SimpleBackup
  class DSL
    @@logger = Logger.instance

    def initialize(engine)
      @storage = Storage.new
      @engine = engine
      @engine.storage = @storage
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
      @engine.apps_block = block
    end

    def mysql(&block)
      @engine.mysql_block = block
    end

    def mailer(&block)
      @mailer = Mailer.new(@engine, @storage)
      @mailer.instance_eval(&block)
    end
  end
end

