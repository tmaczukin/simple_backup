require 'singleton'
require 'simple_backup/source/abstract'

module SimpleBackup
  class Sources
    include Singleton

    def initialize
      @sources = {}
      @default_keep_last = 5
    end

    def each(&block)
      @sources.each do |type, sources|
        sources.each(&block)
      end
    end

    def default_keep_last=(value)
      @default_keep_last = value
    end

    def method_missing(method, *args)
      source = create_source(method)

      return nil if source.nil?

      source.keep_last = @default_keep_last
      source.configure(*args)

      type = source.type.to_sym
      @sources[type] = [] if @sources[type].nil?
      @sources[type] << source
    end

    private
    def create_source(name)
      file = "simple_backup/source/#{name}"

      require file
      source = Object.const_get("SimpleBackup::Source::#{name.capitalize}")
      source.new
    end
  end
end
