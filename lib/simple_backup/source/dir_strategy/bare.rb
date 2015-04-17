module SimpleBackup
  module Source
    module DirStrategy
      class Bare
        def get_entries(path)
          ::Dir.entries(path).map do |p|
            if p.match(/^\.\.?$/)
              nil
            else
              ::File.join(path, p)
            end
          end.compact
        end
      end
    end
  end
end
