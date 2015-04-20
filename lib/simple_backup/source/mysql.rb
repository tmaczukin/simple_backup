module SimpleBackup
  module Source
    class Mysql < Abstract
      @@mysql = Utils::MySQL.instance

      def configure(options = {})
        @db = @name unless options[:db]
        @db = options[:db] if options[:db]

        @exclude_tables = options[:exclude_tables] if options[:exclude_tables]
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
