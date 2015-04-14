module SimpleBackup
  module Engine
    class Abstract
      @keep_last = 5

      def storage=(storage)
        @storage = storage.space(self.class.name.split('::').last)
      end

      def keep_last(value)
        @keep_last = value.to_i
        @keep_last = 5 unless @keep_last > 0
      end

      def cleanup
        path = @storage.dir.path

        backups = Dir.glob(File.join(path, '**/*.tar.gz')).map do |file|
          file if file.match(/.*\.tar\.gz/)
        end.compact.sort

        to_persist = backups
        to_persist = backups.slice(@keep_last * -1, @keep_last) if backups.length > @keep_last
        to_remove = backups - to_persist

        to_remove.each do |file|
          Logger::info "Removing old backup #{file}"
          FileUtils.rm(file)
        end
      end

      def sources
        raise NotImplementedError
      end

      def backup
        raise NotImplementedError
      end
    end
  end
end

