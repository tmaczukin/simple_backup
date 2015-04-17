module SimpleBackup
  module Source
    class Dir < Abstract
      @type = :bare

      def configure(path, options = {})
        @path = path

        @type = options[:type] if options[:type]
        @keep_last = options[:keep_last] if options[:keep_last]
      end

      def desc
        "#{@path}, type: #{@type}"
      end
    end
  end
end
