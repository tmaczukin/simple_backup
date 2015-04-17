module SimpleBackup
  module Source
    class Mysql < Abstract
      def configure(db, options = {})
        @db = db

        @exclude_tables = options[:exclude_tables] if options[:exclude_tables]
        @keep_last = options[:keep_last] if options[:keep_last]
      end

      def desc
        exclude_tables = ", exclude_tables: [#{@exclude_tables.join(', ')}]" if @exclude_tables
        "#{@db}#{exclude_tables}"
      end
    end
  end
end
