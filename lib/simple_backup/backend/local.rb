module SimpleBackup
  module Backend
    class Local < Abstract
      def configure(options = {})
        raise "Must provide :path option" unless options[:path]

        @path = options[:path]

        raise "#{@path} does not exists" unless ::File.exist?(@path)
        raise "#{@path} is not a directory" unless ::File.directory?(@path)
        raise "#{@path} is not writable" unless ::File.writable?(@path)
      end

      def store(source)
        storage_path = get_storage_path(source)
        FileUtils.cp source.backup_file, storage_path
      end

      def cleanup(source)
        storage_path = get_storage_path(source)

        files = ::Dir.glob(::File.join(storage_path, '*.tar.gz')).sort

        to_persist = files
        to_persist = files.slice(source.keep_last * -1, source.keep_last) if files.length > source.keep_last
        to_remove = files - to_persist

        logger.scope_start
        to_remove.each do |file|
          FileUtils.rm(file)
          logger.debug "Old backup '#{file}' for source '#{source.desc.strip}' cleaned up from '#{desc.strip}'"
        end
        logger.scope_end
      end

      private

      def get_storage_path(source)
        path = ::File.join(@path, source.type, source.name)
        FileUtils.mkpath path unless ::File.exist?(path)

        path
      end
    end
  end
end
