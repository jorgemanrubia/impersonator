require 'bundler/setup'
require 'impersonator'
require 'zeitwerk'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expose_dsl_globally = true

  ::Impersonator.logger.level = Logger::DEBUG

  Dir['spec/support/hooks/**/*.rb'].each do |f|
    load f
  end

  loader = Zeitwerk::Loader.for_gem
  loader.push_dir('spec/support')
  loader.setup

  config.include Test::FileHelpers
end
