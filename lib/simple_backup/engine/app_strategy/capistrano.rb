module SimpleBackup
  module Engine
    module AppStrategy
      class Capistrano < Abstract
        @@logger = Logger.instance

        def backup(name, path, attr)
          shared = get_shared_path(path, attr)
          current = get_current_path(path, attr)

          paths = [current, shared].compact

          if paths.empty?
            @@logger.warning "No capistrano paths for application"
            return false
          end

          @storage.backup do |dir|
            FileUtils.cp_r paths, dir
          end

          true
        end

        private
        def get_current_path(path, attr)
          current = Dir.new(File.join(path, attr[:current] || 'current') + '/')
          @@logger.debug "Capistrano current path: #{current.path}"
          current
        rescue Errno::ENOENT
          @@logger.warning "No capistrano current path for application"
          nil
        end

        def get_shared_path(path, attr)
          shared = Dir.new(File.join(path, attr[:shared] || 'shared'))
          @@logger.debug "Capistrano shared path: #{shared.path}"
          shared
        rescue Errno::ENOENT
          @@logger.warning "No capistrano shared path for application"
          nil
        end
      end
    end
  end
end
