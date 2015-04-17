module SimpleBackup
  module Source
    class File < Abstract
      def configure(path, options = {})
        @path = path

        @keep_last = options[:keep_last] if options[:keep_last]
      end
    end
  end
end
