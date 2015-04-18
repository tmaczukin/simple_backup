require 'singleton'

module SimpleBackup
  class Backends
    include Singleton

    def save(backup_files)
      puts backup_files
    end
  end
end
