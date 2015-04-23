require 'fileutils'
require 'rubygems/package'
require 'securerandom'
require 'tmpdir'
require 'tempfile'
require 'zlib'

class Gem::Package::TarWriter
  LONGLINK_NAME = '././@LongLink'

  def add_long_link(name, mode)
    check_closed

    raise Gem::Package::NonSeekableIO unless @io.respond_to? :pos=

    init_pos = @io.pos
    @io.write "\0" * 512 # placeholder for the header
    @io.write name
    size = @io.pos - init_pos - 512

    remainder = (512 - (size % 512)) % 512
    @io.write "\0" * remainder

    final_pos = @io.pos
    @io.pos = init_pos

    header = Gem::Package::TarHeader.new name: LONGLINK_NAME, mode: mode,
                                         size: size, prefix: '',
                                         typeflag: 'L'

    @io.write header
    @io.pos = final_pos

    self
  end

  def add_longname_file(*arguments)
    tries ||= 1
    if block_given?
      add_file(*arguments, &Proc.new)
    else
      add_file(*arguments)
    end
  rescue Gem::Package::TooLongFileName => e
    add_long_link *arguments
    arguments.first.slice!(0, 100)

    retry if (tries -= 1) >= 0
    raise e
  end
end

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

        @tmp_dir = ::File.join(get_tmp, "simple_backup-#{SimpleBackup::TIMESTAMP}-#{SecureRandom.uuid}")
        FileUtils.mkdir_p @tmp_dir, mode: 0700

        @@logger.debug "Created tmp directory #{@tmp_dir}"

        data_exists = prepare_data
        archive_data if data_exists

        @@logger.warning "No data for: #{desc}" unless data_exists

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

        targz

        @@logger.debug "Backup saved to temporary file #{backup_file}"
      end

      def get_tmp
        tmp = @tmp_base_path
        tmp = ::Dir.tmpdir unless tmp
        tmp
      end

      def targz
        path = @tmp_dir

        tempfile = Tempfile.new("#{type}-#{name}", get_tmp)
        @@logger.debug tempfile.path

        Gem::Package::TarWriter.new(tempfile) do |tar|
          @@logger.debug "Opened tar archive #{tar}"
          ::Dir[::File.join(path, '**/*')].each do |file|
            @@logger.debug "Adding file #{file}"
            mode = ::File.stat(file).mode
            relative_file = file.sub(/^#{Regexp::escape path}\/?/, '')

            if ::File.directory?(file)
              tar.mkdir(relative_file, mode)
            else
              tar.add_longname_file relative_file, mode do |tf|
                ::File.open(file, 'rb') do |f|
                  while f_content = f.read(1048576)
                    tf.write f_content
                  end
                end
              end
            end
          end
        end

        gz = ::File.open(@backup_file, 'w')
        Zlib::GzipWriter.open(gz) do |zip|
          tempfile.seek(0)
          while f_content = tempfile.read(1048576)
            zip.write f_content
          end
        end

        tempfile.close
        tempfile.unlink
      end
    end
  end
end
