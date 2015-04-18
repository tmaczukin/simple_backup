module SimpleBackup
  module Source
    class Dir < Abstract
      def initialize
        @strategy = :bare
      end

      def configure(path, options = {})
        @path = path

        raise "#{path} is a file - use File source instead of Dir" unless ::File.directory?(path)

        @type = options[:strategy] if options[:strategy]
        @keep_last = options[:keep_last] if options[:keep_last]
      end

      private
      def prepare_data
        path_entries = get_path_entries
        FileUtils.cp_r path_entries, @tmp_dir if path_entries
      end

      def get_path_entries
        file = "simple_backup/source/dir_strategy/#{@strategy.to_s}"

        require file
        strategy_name = Object.const_get("SimpleBackup::Source::DirStrategy::#{@strategy.to_s.capitalize}")
        strategy = strategy_name.new

        strategy.get_entries(@path)
      rescue Errno::ENOENT
        @@logger.warning "App path does not exists"
        nil
      end
    end
  end
end
