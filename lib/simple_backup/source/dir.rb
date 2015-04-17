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

      private
      def prepare_data
        path_entries = get_path_entries(@path).map do |p|
          if p.match(/^\.\.?$/)
            nil
          else
            ::File.join(@path, p)
          end
        end.compact

        FileUtils.cp_r path_entries, @tmp_dir
      end

      def get_path_entries(path)
        ::Dir.entries(path)
      rescue Errno::ENOENT
        @@logger.warning "App path does not exists"
        nil
      end
    end
  end
end
