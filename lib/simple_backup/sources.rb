require 'singleton'
require 'simple_backup/source/abstract'

module SimpleBackup
  class Sources
    include Singleton

    attr_writer :logger

    @tmp_dir = nil

    def initialize
      @sources = {}
      @default_keep_last = 5
    end

    def default_keep_last=(value)
      @default_keep_last = value
    end

    def tmp_dir(path)
      raise "Temporary path '#{path}' does not exists" unless ::File.exist?(path)
      raise "Temporary path '#{path}' is not a directory" unless ::File.directory?(path)
      raise "Temporary path '#{path}' is not writable" unless ::File.writable?(path)
      @tmp_dir = path
      logger.info "Replaced temporary path to '#{@tmp_dir}'"
    end

    def each(&block)
      @sources.each do |type, sources|
        sources.each(&block)
      end
    end

    def backup
      @sources.each do |type, sources|
        sources.each do |name, source|
          source.get
        end
      end
    end

    def cleanup
      each do |name, source|
        source.cleanup
      end
    end

    def method_missing(method, *args)
      source = create_source(method)

      return nil if source.nil?

      name = args.shift
      options = args.shift
      options ||= {}

      type = source.type.to_sym
      @sources[type] = {} if @sources[type].nil?
      raise "Name '#{name}' for source #{type} already used" if @sources[type].has_key?(name.to_sym)

      source.keep_last = @default_keep_last
      source.keep_last = options[:keep_last] if options[:keep_last]
      source.backends = options[:backends] if options[:backends]
      source.tmp_base_path = @tmp_dir if @tmp_dir
      source.name = name

      source.configure(options)

      logger.info "Created source for: #{source.desc.strip}"

      @sources[type][name.to_sym] = source
    end

    private

    def create_source(name)
      file = "simple_backup/source/#{name}"

      require file
      source_name = Object.const_get("SimpleBackup::Source::#{name.capitalize}")
      source_name.new
    end

    def logger
      Utils::Logger.instance unless @logger
      @logger if @logger
    end
  end
end
