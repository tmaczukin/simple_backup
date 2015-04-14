module SimpleBackup
  module Engine
    module AppStrategy
      class Abstract
        attr_accessor :storage

        def backup(name, path, attr)
          raise NotImplementedError
        end
      end
    end
  end
end
