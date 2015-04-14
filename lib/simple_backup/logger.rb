require 'colorize'

module SimpleBackup
  class Logger
    TIME_FORMAT = '%Y-%m-%dT%H:%M:%S'

    @@buffer = []
    @@scope = 0
    @@level = :info
    @@levels = {
      debug: {weight: 3, color: :light_cyan},
      info: {weight: 2, color: :green},
      warning: {weight: 1, color: :light_yellow},
      error: {weight: 0, color: :red}
    }

    banner = "LOG STARTED #{Time.new.strftime('%Y-%m-%dT%H:%M:%S')}"
    banner2 = "SimpleBackup v#{SimpleBackup::Version::get}"

    banner_length = 0
    banner_length = banner.length if  banner.length > banner_length
    banner_length = banner2.length if banner2.length > banner_length
    banner_length = 80 if 80 > banner_length

    border = '=' * ((banner_length - banner.length) / 2).ceil.to_i
    @@buffer << "#{border}==[ #{banner} ]==#{border}"
    border = '=' * ((banner_length - banner2.length) / 2).ceil.to_i
    @@buffer << "#{border}==[ #{banner2} ]==#{border}"
    puts @@buffer[0].green
    puts @@buffer[1].green

    def self.level=(level)
      self.check_level(level)
      @@level = level
    end

    def self.scope_start(level = nil, message = nil)
      self.log level, message unless level.nil? and message.nil?
      @@scope += 1
    end

    def self.scope_end(level = nil, message = nil)
      self.log level, message unless level.nil? and message.nil?
      @@scope -= 1
    end

    def self.debug(message)
      self.log(:debug, message)
    end

    def self.info(message)
      self.log(:info, message)
    end

    def self.warning(message)
      self.log(:warning, message)
    end

    def self.error(message)
      self.log(:error, message)
    end

    def self.log(level, message)
      self.check_level(level)

      color = @@levels[level][:color]
      should_write = @@levels[level][:weight] <= @@levels[@@level][:weight]

      scope_prefix = '..' * @@scope
      message = "%s %7s: %s%s" % [Time.new.strftime(TIME_FORMAT), level.to_s.upcase, scope_prefix, message]
      @@buffer << message

      puts message.colorize(color: color) if should_write
    end

    def self.check_level(level)
      raise "Unknown logging level #{level}" unless @@levels.has_key?(level)
    end

    def self.buffer
      @@buffer
    end
  end
end
