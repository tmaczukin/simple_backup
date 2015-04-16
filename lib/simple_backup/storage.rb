require 'rubygems/package'
require 'zlib'
require 'fileutils'

module SimpleBackup
  class Storage
    attr_accessor :dir

    @@created_files = []

    def dir=(dir)
      @dir = get_dir(dir)

      Logger::info "Backup dir set to '#{dir}'"
    end

    def space(space)
      Logger::debug "Setting backup_dir for space '#{space}'"
      storage = Storage.new
      storage.dir = File.join(@dir.path, format_for_path(space))
      storage
    end

    def backup
      dir = get_dir(File.join(@dir, TIMESTAMP))
      yield(dir)

      targz = targz(dir)
      backup_file = File.join(@dir, TIMESTAMP) + '.tar.gz'

      File.open(backup_file, 'w') do |f|
        f.write targz.string
      end

      FileUtils.rm_r dir.path

      @@created_files.push backup_file
      backup_file
    end

    def created_files
      @@created_files
    end

    private
    def get_dir(dir)
      tries ||= 2
      Dir.new(dir)
    rescue Errno::ENOENT
      recreate_dir(dir)
      retry unless (tries -= 1).zero?
    end

    def recreate_dir(dir)
      Dir.mkdir(dir, 0755)

      Logger::warning "Recreated non-existing directory '#{dir}'"
    rescue Errno::EACCES => e
      raise Exception::CantCreateDir.new(e.message)
    end

    def format_for_path(value)
      value.downcase.gsub(/[^a-zA-Z0-9\-\_\.]*/, '').gsub(/\s+/, '_')
    end

    def targz(dir)
      path = dir.path
      content = StringIO.new('');
      Gem::Package::TarWriter.new(content) do |tar|
        Dir[File.join(path, '**/*')].each do |file|
          mode = File.stat(file).mode
          relative_file = file.sub(/^#{Regexp::escape path}\/?/, '')

          if File.directory?(file)
            tar.mkdir(relative_file, mode)
          else
            tar.add_file relative_file, mode do |tf|
              File.open(file, 'rb') do |f|
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
