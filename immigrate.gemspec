# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'immigrate/version'

Gem::Specification.new do |spec|
  spec.name          = 'immigrate'
  spec.version       = Immigrate::VERSION
  spec.authors       = ['Brian VanLoo']
  spec.email         = ['brian.vanloo@gmail.com']

  spec.summary       = 'Support for PostgreSQL foreign data wrappers in Rails migrations'
  spec.description   = 'Adds methods to ActiveRecord::Migration to create and manage foreign-data wrappers in PostgreSQL.'
  spec.homepage      = 'https://github.com/ratdaddy/immigrate'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'railties', '>= 4.0.0'
  spec.add_dependency 'activerecord', '>= 4.0.0'
  spec.add_dependency 'pg'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'database_cleaner'
end
