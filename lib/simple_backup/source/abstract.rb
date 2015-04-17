require 'rubygems/package'
require 'tmpdir'
require 'zlib'

module SimpleBackup
  module Source
    class Abstract
      @@logger = Logger.instance

      def configure(*args)
        raise NotImplementedError
      end

      def keep_last=(value)
        @keep_last = value
      end

      def type
        self.class.name.split('::').last
      end

      def desc
        raise NotImplementedError
      end

      def get
        @@logger.scope_start :info, "Getting archive for: #{type} :: #{desc}"

        @tmp_dir = ::Dir.mktmpdir('simple_backup-')
        @@logger.debug "Created tmp directory #{@tmp_dir}"

        prepare_data
        archived_data = archive_data

        FileUtils.rm_rf(@tmp_dir)
        @@logger.debug "Removed tmp directory #{@tmp_dir}"

        archived_data
      ensure
        @@logger.scope_end
      end

      private
      def prepare_data
        raise NotImplementedError
      end

      def archive_data
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
