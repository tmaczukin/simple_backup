module SimpleBackup
  module Source
    class Dir < Abstract
      def initialize
        @strategy = :bare
      end

      def configure(options = {})
        raise "Must provide :path parameter" unless options[:path]
        @path = options[:path]

        raise "#{@path} is a file - use File source instead of Dir" unless !::File.exist?(@path) or ::File.directory?(@path)
        @strategy = options[:strategy] if options[:strategy]
      end

      private
      def prepare_data
        return false unless ::File.exist?(@path)

        path_entries = get_path_entries
        FileUtils.cp_r path_entries, @tmp_dir if path_entries

        true
      end

      def get_path_entries
        file = "simple_backup/source/dir_strategy/#{@strategy.to_s}"

        require file
        strategy_name = Object.const_get("SimpleBackup::Source::DirStrategy::#{@strategy.to_s.capitalize}")
        strategy = strategy_name.new

        strategy.get_entries(@path)
      rescue Errno::ENOENT
        @@logger.warning "Path '#{@path}' does not exists"
        nil
      end
    end
  end
end
