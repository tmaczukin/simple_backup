require 'simple_backup/engine/app_strategy/factory'

module SimpleBackup
  module Engine
    class Apps < Abstract
      @@logger = Logger.instance

      def initialize
        @apps = {}
        @strategies = {}
      end

      def app(path, attr = {})
        @@logger.debug "Adding application #{path} #{attr}"
        raise Exception::AppAlreadyDefined.new "Application '#{path}' is already defined" if @apps.has_key?(path)

        @apps[path] = attr
      end

      def backup
        @apps.each do |path, attr|
          next unless app_exists(path)
          backup_app(path, attr)
        end
      end

      def sources
        sources = []
        @apps.each do |path, attr|
          sources << path
        end

        sources
      end

      private
      def backup_app(path, attr)
        name = path.split('/').last
        @@logger.scope_start :info, "Backup of application #{name} started"
        @@logger.debug "name: #{name}, attr: #{attr}"

        strategy = get_strategy(attr[:type])
        strategy.storage = @storage.space(name)
        is_backuped = strategy.backup(name, path, attr)

        @@logger.scope_end :info, "Backup of application #{name} finished" if is_backuped
        @@logger.scope_end :info, "Backup of application #{name} skipped" unless is_backuped
      end

      def app_exists(path)
        Dir.new(path)
        true
      rescue Errno::ENOENT
        @@logger.warning "App path '#{path}' does not exists"
        false
      end

      def get_strategy(type)
        return @strategies[type] if @strategies.has_key?(type)

        AppStrategy::Factory.create(type)
      end
    end
  end
end
