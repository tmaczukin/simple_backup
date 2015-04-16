require 'mysql2'

module SimpleBackup
  module Engine
    class MySQL < Abstract
      @@logger = Logger.instance

      def initialize
        @host = 'localhost'
        @port = 3306
        @user = nil
        @pass = nil
        @dbs = {}
      end

      def host(host)
        @host = host
      end

      def port(port)
        @port = port
      end

      def user(user)
        @user = user
      end

      def pass(pass)
        @pass = pass
      end

      def db(name, attr = {})
        @@logger.debug "Adding database #{name} #{attr}"
        raise Exception::AppAlreadyDefined.new "Database '#{name}' is already defined" if @dbs.has_key?(name)

        @dbs[name] = attr
      end

      def backup
        @conn = Mysql2::Client.new(host: @host, username: @user, password: @pass, port: @port)

        prepare_tables
        return if @dbs.empty?

        @storage.backup do |dir|
          @dbs.each do |db, attr|
            dump_db(dir, db, attr)
          end
        end
      ensure
        @conn.close unless @conn.nil?
      end

      def sources
        sources = []
        @dbs.each do |db, attr|
          sources << db
        end

        sources
      end

      private
      def prepare_tables
        @existing_dbs = []
        @conn.query("SHOW DATABASES").each do |row|
          @existing_dbs << row['Database']
        end

        dbs = {}
        @dbs.each do |db, attr|
          dbs[db] = attr if check_database_exists?(db)
        end

        @dbs = dbs
        @dbs.each do |db, attr|
          tables = []
          @conn.query("SHOW TABLES FROM `#{db}`").each do |row|
            tables << row["Tables_in_#{db}"]
          end
          tables = tables - attr[:exclude_tables] if attr[:exclude_tables]

          @dbs[db][:tables] ||= tables
        end
      end

      def check_database_exists?(db)
        if @existing_dbs.include?(db)
          return true
        end
        @@logger.warning "Database '#{db}' does not exists"
      end

      def dump_db(dir, db, attr)
        @@logger.scope_start :info, "Backup of mysql database #{db} started"

        file = File.join(dir, db) + '.sql'
        cmd = "mysqldump --flush-logs --flush-privileges --order-by-primary --complete-insert -C -h #{@host} -u #{@user} -p#{@pass} #{db} #{attr[:tables].join(' ')} > #{file}"
        @@logger.debug "Running command: #{cmd}"
        `#{cmd}`

        @@logger.scope_end :info, "Backup of mysql database #{db} finished"
      end
    end
  end
end
