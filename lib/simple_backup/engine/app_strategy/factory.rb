require 'simple_backup/engine/app_strategy/abstract'

module SimpleBackup
  module Engine
    module AppStrategy
      class Factory
        @@types = [:bare, :capistrano]

        def self.create(type)
          raise Exception::TypeDoesNotExists.new "Strategy type '#{type}' does not exists" unless @@types.include?(type)
          file = "simple_backup/engine/app_strategy/#{type.to_s}"

          require file
          strategy = Object.const_get("SimpleBackup::Engine::AppStrategy::#{type.to_s.capitalize}")
          strategy.new
        end
      end
    end
  end
end
