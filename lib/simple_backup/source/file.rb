module SimpleBackup
  module Source
    class File < Abstract
      def configure(path, options = {})
        @path = path

        raise "#{path} is a directory - use Dir source instead of File" unless !::File.exist?(path) or ::File.file?(path)

        @keep_last = options[:keep_last] if options[:keep_last]
      end

      private
      def prepare_data
        return false unless ::File.exist?(@path)

        FileUtils.cp @path, @tmp_dir

        true
      end
    end
  end
end
