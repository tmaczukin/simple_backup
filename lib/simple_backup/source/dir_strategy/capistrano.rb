module SimpleBackup
  module Source
    module DirStrategy
      class Capistrano
        @@logger = Utils::Logger.instance

        def get_entries(path)
          shared = shared_path(path)
          current = current_path(path)
          paths = [current, shared].compact

          if paths.empty?
            @@logger.warning "No capistrano paths for application"
            return nil
          end

          paths
        end

        private
        def current_path(path)
          current = ::Dir.new(::File.join(path, 'current') + '/')
          @@logger.debug "Capistrano current path: #{current.path}"
          current.path
        rescue Errno::ENOENT
          @@logger.warning "No capistrano current path for application"
          nil
        end

        def shared_path(path)
          shared = ::Dir.new(::File.join(path, 'shared'))
          @@logger.debug "Capistrano shared path: #{shared.path}"
          shared.path
        rescue Errno::ENOENT
          @@logger.warning "No capistrano shared path for application"
          nil
        end
      end
    end
  end
end
