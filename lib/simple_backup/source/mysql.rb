module SimpleBackup
  module Source
    class Mysql < Abstract
      @@mysql = Utils::MySQL.instance

      def configure(db, options = {})
        @db = db

        @exclude_tables = options[:exclude_tables] if options[:exclude_tables]
        @keep_last = options[:keep_last] if options[:keep_last]
      end

      private
      def prepare_data
        @@mysql.open

        tables = @@mysql.scan_tables(@db)
        return false if tables.nil?

        tables = tables - @exclude_tables if @exclude_tables
        dumpfile = ::File.join(@tmp_dir, @db) + '.sql'

        @@mysql.dump(@db, tables, dumpfile)

        true
      end
    end
  end
end
