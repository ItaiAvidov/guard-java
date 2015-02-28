# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/java/version'

Gem::Specification.new do |s|
  s.name        = 'guard-java'
  s.version     = Guard::JavaVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Tony C. Heupel']
  s.email       = ['tony@heupel.net']
  s.homepage    = 'http://github.com/infospace/guard-java'
  s.summary     = 'Guard gem for Java'
  s.description = 'Guard::Java automatically run your unit tests when you save files (much like Eclipse\'s Build on Save'
  s.licenses    = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'guard-rspec'

  s.add_dependency 'guard', '>= 1.1'
  s.add_dependency 'rspec', '~> 2.11'

  s.add_development_dependency 'bundler', '~> 1.1'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.require_path = 'lib'
end
