module SimpleBackup
  module Source
    class File < Abstract
      def configure(options = {})
        raise "Must provide :path parameter" unless options[:path]
        @path = options[:path]

        raise "#{@path} is a directory - use Dir source instead of File" unless !::File.exist?(@path) or ::File.file?(@path)
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
