# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

CLEAN << '.rspec_status'
CLEAN << 'GEMFILE.lock'
CLEAN << 'coverage'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

desc 'run all RSpec examples and collect code coverage'
task :coverage do
  ENV['COVERAGE'] = 'on'
  Rake::Task['spec'].execute
end

task default: [:spec]
