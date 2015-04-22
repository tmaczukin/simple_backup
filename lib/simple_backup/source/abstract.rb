require 'fileutils'
require 'rubygems/package'
require 'securerandom'
require 'tmpdir'
require 'zlib'

module SimpleBackup
  module Source
    class Abstract
      @@logger = Utils::Logger.instance
      @tmp_base_path = nil

      def configure(options = {})
        raise NotImplementedError
      end

      def keep_last=(value)
        @keep_last = value
      end

      def keep_last
        @keep_last
      end

      def name=(value)
        @name = value.gsub(/[^a-zA-Z0-9\-\_\. ]*/, '').gsub(/\s+/, '_').downcase
      end

      def name
        @name
      end

      def tmp_base_path=(value)
        @tmp_base_path = value
      end

      def type
        self.class.name.split('::').last.gsub(/[^a-zA-Z0-9\-\_\. ]*/, '').gsub(/\s+/, '_').downcase
      end

      def desc
        '%5s :: %s' % [type, @name]
      end

      def get
        return @backup_file if @backup_file

        @@logger.scope_start :info, "Getting archive for: #{desc}"

        prepare_tmp_dir
        data_exists = prepare_data

        @@logger.warning "No data for: #{desc}" unless data_exists
        archive_data if data_exists

        FileUtils.rm_rf(@tmp_dir)
        @@logger.debug "Removed tmp directory #{@tmp_dir}"

        @backup_file
      ensure
        @@logger.scope_end
      end

      def cleanup
        return nil unless @backup_file

        FileUtils.rm (@backup_file)
        @@logger.debug "Temporary backup file #{@backup_file} was removed"
      end

      def backup_file
        @backup_file
      end

      def backends=(value)
        @backends = []
        @backends = @backends + value if value.kind_of?(Array)
        @backends << value unless value.kind_of?(Array)
      end

      def supports(backend)
        return TRUE unless @backends
        return FALSE unless @backends.include?(backend.name)

        TRUE
      end

      private
      def prepare_data
        raise NotImplementedError
      end

      def archive_data
        filename = "#{type}-#{name}.#{SimpleBackup::TIMESTAMP}.tar.gz"
        @backup_file = ::File.join(get_tmp, filename)

        ::File.open(backup_file, 'w') do |f|
          f.write targz.string
        end

        @@logger.debug "Backup saved to temporary file #{backup_file}"
      end

      def prepare_tmp_dir
        @tmp_dir = ::File.join(get_tmp, "simple_backup-#{SimpleBackup::TIMESTAMP}-#{SecureRandom.uuid}")
        FileUtils.mkdir_p @tmp_dir, mode: 0700

        @@logger.debug "Created tmp directory #{@tmp_dir}"
      end

      def get_tmp
        tmp = @tmp_base_path
        tmp = ::Dir.tmpdir unless tmp

        tmp
      end

      def targz
        path = @tmp_dir

        content = StringIO.new('');
        Gem::Package::TarWriter.new(content) do |tar|
          ::Dir[::File.join(path, '**/*')].each do |file|
            mode = ::File.stat(file).mode
            relative_file = file.sub(/^#{Regexp::escape path}\/?/, '')

            if ::File.directory?(file)
              tar.mkdir(relative_file, mode)
            else
              tar.add_file relative_file, mode do |tf|
                ::File.open(file, 'rb') do |f|
                  tf.write f.read
                end
              end
            end
          end
        end
        content.rewind

        gz = StringIO.new('')
        zip = Zlib::GzipWriter.new(gz)
        zip.write content.string
        zip.close

        gz
      end
    end
  end
end
