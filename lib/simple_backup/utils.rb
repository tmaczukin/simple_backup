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
  end
end
