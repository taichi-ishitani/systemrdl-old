# frozen_string_literal: true

require 'bundler/setup'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

if ENV['COVERAGE'] && ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'systemrdl'
