require 'singleton'
require 'mysql2'

module SimpleBackup
  module Utils
    class Disk
      @@high_usage_treshold = 0.9
      @@paths = []

      def self.high_usage_treshold=(value)
        @@high_usage_treshold = value.to_f

        raise ArgumentError.new "Backuper::Utils::Disk::high_usage_treshold must be a float greater than zero" if @@high_usage_treshold <= 0.0
      end

      def self.high_usage_treshold
        @@high_usage_treshold
      end

      def self.add_path(path)
        @@paths << path unless @@paths.include?(path)
      end

      def self.usage
        df = `df -m #{@@paths.join(' ')} 2>/dev/null`.split("\n")
        df.shift

        max_percent = 0.0;
        df.map! do |row|
          row = row.split(' ')

          percent_usage = (row[4].gsub('%', '').to_f / 100).round(2)
          row = {
            mount: row[5],
            fs: row[0],
            size: row[1],
            used: row[2],
            available: row[3],
            percent: percent_usage,
            high_usage_exceeded: percent_usage >= @@high_usage_treshold
          }

          max_percent = row[:percent] if row[:percent] > max_percent

          row
        end

        {
          mounts: df.uniq,
          high_usage_exceeded: max_percent >= @@high_usage_treshold,
          high_usage: max_percent
        }
      end
    end

    class MySQL
      include Singleton

      @@logger = ::SimpleBackup::Logger.instance

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
