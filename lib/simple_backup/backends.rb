require 'singleton'
require 'simple_backup/backend/abstract'

module SimpleBackup
  class Backends
    include Singleton

    attr_writer :logger

    @@sources = Sources.instance

    def initialize
      @backends = {}
    end

    def each(&block)
      @backends.each(&block)
    end

    def save_and_cleanup
      each do |name, backend|
        @@sources.each do |name, source|
          next unless source.backup_file and source.supports(backend)

          backend.store(source)
          logger.info "Source '#{source.desc.strip}' stored in backend '#{backend.desc.strip}'"

          backend.cleanup(source)
          logger.info "Source '#{source.desc.strip}' cleaned up in backend '#{backend.desc.strip}'"
        end
      end
    end

    def method_missing(method, *args)
      backend = create_backend(method)

      return nil if backend.nil?

      name = args.shift
      options = args.shift
      options ||= {}

      raise "Name '#{name}' for backend already used" if @backends.has_key?(name.to_sym)

      backend.name = name
      backend.configure(options)

      logger.info "Created backend for: #{backend.desc}"
      @backends[name.to_sym] = backend
    end

    private

    def create_backend(name)
      file = "simple_backup/backend/#{name}"

      require file
      backend_name = Object.const_get("SimpleBackup::Backend::#{name.capitalize}")
      backend_name.new
    end

    def logger
      Utils::Logger.instance unless @logger
      @logger if @logger
    end
  end
end
