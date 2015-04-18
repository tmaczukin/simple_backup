require 'singleton'
require 'mysql2'

module SimpleBackup
  module Utils
    class MySQL
      include Singleton

      @@logger = Logger.instance

      def initialize
        @host = 'localhost'
        @port = 3306
        @user = nil
        @pass = nil
      end

      def open
        return nil unless @conn.nil?

        @conn = Mysql2::Client.new(host: @host, port: @port, username: @user, password: @pass)
        @existing_dbs = []
        @conn.query("SHOW DATABASES").each do |row|
          @existing_dbs << row['Database']
        end
      end

      def close
        @conn.close unless @conn.nil?
      end

      def scan_tables(db)
        return nil unless @existing_dbs.include?(db)

        tables = []
        @conn.query("SHOW TABLES FROM `#{db}`").each do |row|
          tables << row["Tables_in_#{db}"]
        end
        tables
      end

      def dump(db, tables, dumpfile)
        cmd = "mysqldump --flush-logs --flush-privileges --order-by-primary --complete-insert -C -h #{@host} -u #{@user} -p#{@pass} #{db} #{tables.join(' ')} > #{dumpfile}"
        @@logger.debug "Running command: #{cmd}"
        `#{cmd}`
      end

      def host(value)
        @host = value
      end

      def port(value)
        @port = value
      end

      def user(value)
        @user = value
      end

      def pass(value)
        @pass = value
      end
    end
  end
end
