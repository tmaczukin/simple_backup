require 'bundler/setup'
require 'simplecov'

SimpleCov.start
Bundler.require

RSpec.configure do |config|
  config.profile_examples = 2
  config.order = :random
  Kernel.srand config.seed
end
