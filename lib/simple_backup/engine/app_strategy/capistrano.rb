module SimpleBackup
  module Engine
    module AppStrategy
      class Capistrano < Abstract
        def backup(name, path, attr)
          shared = get_shared_path(path, attr)
          current = get_current_path(path, attr)

          paths = [current, shared].compact

          if paths.empty?
            Logger::warning "No capistrano paths for application"
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
          Logger::debug "Capistrano current path: #{current.path}"
          current
        rescue Errno::ENOENT
          Logger::warning "No capistrano current path for application"
          nil
        end

        def get_shared_path(path, attr)
          shared = Dir.new(File.join(path, attr[:shared] || 'shared'))
          Logger::debug "Capistrano shared path: #{shared.path}"
          shared
        rescue Errno::ENOENT
          Logger::warning "No capistrano shared path for application"
          nil
        end
      end
    end
  end
end
