require 'simple_backup/engine/abstract'
require 'simple_backup/engine/apps'
require 'simple_backup/engine/mysql'

module SimpleBackup
  module Engine
    class Engine
      @@logger = Logger.instance
      @@sources = Sources.instance

      def storage=(storage)
        @storage = storage
      end

      def mailer=(mailer)
        @mailer = mailer
      end

      def run
        usage = Utils::Disk::usage

        @@logger.error "Disk high usage treshold exceeded #{usage[:high_usage]}" if usage[:high_usage_exceeded]
        @@logger.scope_start :info, "Backup job"

        backup_files = @@sources.backup_files
        puts backup_files

        @@logger.scope_end
      end

      def cleanup
        @@logger.scope_start :info, "Cleanup job"

        # cleanup

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
