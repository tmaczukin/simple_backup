require 'singleton'
require 'simple_backup/source/abstract'

module SimpleBackup
  class Sources
    include Singleton

    @@logger = Logger.instance

    def initialize
      @sources = {}
      @default_keep_last = 5
    end

    def default_keep_last=(value)
      @default_keep_last = value
    end

    def each(&block)
      @sources.each do |type, sources|
        sources.each(&block)
      end
    end

    def backup_files
      return @backup_files if @backup_files

      @backup_files = []
      @sources.each do |type, sources|
        sources.each do |name, source|
          backup_files << {
            type: source.type,
            name: source.name,
            file: source.get
          }
        end
      end

      @backup_files
    end

    def method_missing(method, *args)
      source = create_source(method)

      return nil if source.nil?

      name = args.shift
      type = source.type.to_sym
      @sources[type] = {} if @sources[type].nil?
      raise "Name '#{name}' for type #{type} already used" if @sources[type].has_key?(name.to_sym)

      source.keep_last = @default_keep_last
      source.name = name
      configured = source.configure(*args)

      @@logger.info "Created source for: #{source.desc}"

      @sources[type][name.to_sym] = source
    end

    private
    def create_source(name)
      file = "simple_backup/source/#{name}"

      require file
      source_name = Object.const_get("SimpleBackup::Source::#{name.capitalize}")
      source_name.new
    end
  end
end
