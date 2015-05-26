module SimpleBackup
  module Engine
    class Engine
      attr_writer :logger

      @@backends = Backends.instance
      @@sources = Sources.instance
      @@mysql = Utils::MySQL.instance

      def mailer=(mailer)
        @mailer = mailer
      end

      def run
        usage = Utils::Disk::usage

        logger.error "Disk high usage treshold exceeded #{usage[:high_usage]}" if usage[:high_usage_exceeded]
        logger.scope_start :info, "Backup"

        @@sources.backup
        @@backends.save_and_cleanup
        @@sources.cleanup

        logger.scope_end
      ensure
        @@mysql.close
      end

      def notify
        return unless @mailer
        logger.scope_start :info, "Sending e-mail notification"

        @mailer.send

        logger.scope_end :info, "Notifications for backup #{TIMESTAMP} finished"
      rescue StandardError => e
        SimpleBackup.handle_exception(e)
      end

      private

      def logger
        Utils::Logger.instance unless @logger
        @logger if @logger
      end
    end
  end
end
