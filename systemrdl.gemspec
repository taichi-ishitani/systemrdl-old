# frozen_string_literal: true

require File.expand_path('lib/systemrdl/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'systemrdl'
  spec.version = SystemRDL::VERSION
  spec.authors = ['Taichi Ishitani']
  spec.email = ['taichi730@gmail.com']

  spec.summary = 'SystemRDL parser for Ruby'
  spec.homepage = 'https://github.com/taichi-ishitani/systemrdl'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z lib LICENSE CODE_OF_CONDUCT.md README.md`.split("\x0")
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.9.0'
  spec.add_development_dependency 'rubocop', '>= 1.7.0'
end
