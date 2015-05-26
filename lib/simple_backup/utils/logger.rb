require 'colorize'

module SimpleBackup
  module Utils
    # Logger util
    #
    class Logger
      attr_writer :output
      attr_reader :level
      attr_reader :buffer

      TIME_FORMAT = '%Y-%m-%dT%H:%M:%S'

      @_instance = nil

      def self.instance(output = nil)
        return @_instance if @_instance

        @_instance = new
        @_instance.output = output if output
        @_instance.show_banner
        @_instance
      end

      def initialize
        @output = STDOUT
        @buffer = []
        @scope = 0
        @level = :info
        @levels = {
          debug:   { weight: 3, color: :light_cyan },
          info:    { weight: 2, color: :green },
          warning: { weight: 1, color: :light_yellow },
          error:   { weight: 0, color: :red }
        }
      end

      def show_banner
        lines = []
        lines << "LOG STARTED #{Time.new.strftime('%Y-%m-%dT%H:%M:%S')}"
        lines << "SimpleBackup v#{SimpleBackup::Version.get}"
        banner(lines)
      end

      def level=(level)
        check_level(level)
        @level = level
      end

      def scope_start(level = nil, message = nil)
        log(level, message) unless level.nil? && message.nil?
        @scope += 1
      end

      def scope_end(level = nil, message = nil)
        log(level, message) unless level.nil? && message.nil?
        @scope -= 1 unless @scope == 0
      end

      def method_missing(name, *arguments)
        level = name.to_sym
        log(level, arguments.first) if @levels.key?(level)
      end

      def log(level, message)
        check_level(level)
        color = @levels[level][:color]

        scope_prefix = '..' * @scope
        message = format('%s %7s: %s%s', Time.new.strftime(TIME_FORMAT), level.to_s.upcase, scope_prefix, message)

        @buffer << message if should_write(level)
        @output.puts(message.colorize(color: color)) if should_write(level)
      end

      private

      def check_level(level)
        raise "Unknown logging level #{level}" unless @levels.key?(level)
      end

      def should_write(level)
        @levels[level][:weight] <= @levels[@level][:weight]
      end

      def banner(lines)
        banner_length = 0

        lines.each do |line|
          banner_length = line.length if line.length > banner_length
        end
        banner_length = 80 if 80 > banner_length

        lines.each do |line|
          border = '=' * ((banner_length - line.length) / 2).ceil.to_i
          log(:info, "#{border}==[ #{line} ]==#{border}")
        end
      end
    end
  end
end
