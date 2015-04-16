module SimpleBackup
  module Engine
    module AppStrategy
      class Bare < Abstract
        @@logger = Logger.instance

        def backup(name, path, attr)
          app_elements = get_path_entries(path).map do |p|
            if p.match(/^\.\.?$/)
              nil
            else
              File.join(path, p)
            end
          end.compact

          @storage.backup do |dir|
            FileUtils.cp_r app_elements, dir
          end
        end

        private
        def get_path_entries(path)
          Dir.entries(path)
        rescue Errno::ENOENT
          @@logger.warning "App path does not exists"
          nil
        end
      end
    end
  end
end
