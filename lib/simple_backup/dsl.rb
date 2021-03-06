module SimpleBackup
  class DSL
    @@logger = Utils::Logger.instance

    def initialize(engine)
      @engine = engine
    end

    def version(requirement, allow_pre = false)
      current_version = SimpleBackup::Version.get

      @@logger.debug "Version check: is '#{current_version}' matching '#{requirement}'?"

      raise "Incompatible SimpleBackup version. Definition requires '#{requirement}' but used version is '#{current_version}'" unless
               Gem::Dependency.new('simple_backup', requirement).match?('simple_backup', current_version, allow_pre)

      @@logger.info "Version check: OK"
    end

    def log_level(level)
      @@logger.level = level
    end

    def high_usage_treshold(value)
      @@logger.info "Setting high_usage_treshold to #{value}"

      Utils::Disk.high_usage_treshold = value
    end

    def check_disk_path(path)
      @@logger.info "Adding disk path '#{path}' to usage check"

      Utils::Disk.add_path(path)
    end

    def default_keep_last(value)
      Sources.instance.default_keep_last = value
    end

    def sources(&block)
      sources = Sources.instance
      sources.instance_eval(&block)
    end

    def backends(&block)
      backends = Backends.instance
      backends.instance_eval(&block)
    end

    def mysql(&block)
      @@logger.info "Configuring MySQL Util"

      Utils::MySQL.instance.instance_eval(&block)
    end

    def mailer(&block)
      @@logger.info "Configuring Mailer Util"

      @mailer = Utils::Mailer.new
      @mailer.instance_eval(&block)
      @engine.mailer = @mailer
    end
  end
end

