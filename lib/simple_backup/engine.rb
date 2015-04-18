module SimpleBackup
  module Engine
    class Engine

      @@backends = Backends.instance
      @@sources = Sources.instance
      @@logger = Utils::Logger.instance
      @@mysql = Utils::MySQL.instance

      def mailer=(mailer)
        @mailer = mailer
      end

      def run
        usage = Utils::Disk::usage

        @@logger.error "Disk high usage treshold exceeded #{usage[:high_usage]}" if usage[:high_usage_exceeded]
        @@logger.scope_start :info, "Backup job"

        backup_files = @@sources.backup_files
        @@backends.save(backup_files)

        @@logger.scope_end
      ensure
        @@mysql.close
      end

      def cleanup
        @@logger.scope_start :info, "Cleanup job"

        # cleanup

        @@logger.scope_end
      end

      def notify
        return unless @mailer
        @mailer.send

        @@logger.info "Notifications for backup #{TIMESTAMP} finished"
      rescue StandardError => e
        SimpleBackup.handle_exception(e)
      end
    end
  end
end
