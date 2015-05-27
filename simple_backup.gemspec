lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_backup/version'

Gem::Specification.new do |spec|
  spec.name     = 'simple_backup'
  spec.version  = SimpleBackup::Version.instance.get
  spec.authors  = ['Tomasz Maczukin']
  spec.email    = ['tomasz@maczukin.pl']
  spec.summary  = 'Backup tool with simple DSL for configuration'
  spec.homepage = 'https://github.com/tmaczukin/simple_backup'
  spec.license  = 'MIT'

  spec.files            = `git ls-files -z`.split("\x0")
  spec.require_paths    = ['lib']

  spec.add_development_dependency 'rake',      '~> 10.0'
  spec.add_development_dependency 'rspec',     '~> 3.2.0'
  spec.add_development_dependency 'simplecov', '~> 0.10.0'
  spec.add_development_dependency 'rubocop',   '~> 0.31.0'

  spec.add_dependency 'colorize',  '~> 0.7.5'
  spec.add_dependency 'mail',      '~> 2.6.3'
  spec.add_dependency 'mysql2',    '~> 0.3.18'
end
