require 'simple_backup/engine/abstract'
require 'simple_backup/engine/apps'
require 'simple_backup/engine/mysql'

module SimpleBackup
  module Engine
    class Engine
      @@logger = Logger.instance

      def storage=(storage)
        @storage = storage
      end

      def mailer=(mailer)
        @mailer = mailer
      end

      def prepare
        if @apps_block
          @apps = Apps.new
          @apps.storage = @storage
          @apps.instance_eval(&@apps_block)
        end

        if @mysql_block
          @mysql = MySQL.new
          @mysql.storage = @storage
          @mysql.instance_eval(&@mysql_block)
        end
      end

      def run
        usage = Utils::Disk::usage

        @@logger.error "Disk high usage treshold exceeded #{usage[:high_usage]}" if usage[:high_usage_exceeded]
        @@logger.scope_start :info, "Backup job"

        @apps.backup if @apps
        @mysql.backup if @mysql

        @@logger.scope_end
      end

      def cleanup
        @@logger.scope_start :info, "Cleanup job"

        @apps.cleanup if @apps
        @mysql.cleanup if @mysql

        @@logger.scope_end
      end

      def notify
        @mailer.send if @mailer
      rescue StandardError => e
        SimpleBackup.handle_exception(e)
      end
    end
  end
end
