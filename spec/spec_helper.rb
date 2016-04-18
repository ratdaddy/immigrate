$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'immigrate'
require 'database_cleaner'

def dummy_root
  File.expand_path('../dummy', __FILE__)
end

ENV['RAILS_ENV'] = 'test'
Dir.chdir(dummy_root) do
  require "#{dummy_root}/config/environment"
end

RSpec.configure do |config|
  config.around :example, :silence do |example|
    saved_stdout = $stdout
    saved_stderr = $stderr
    $stdout = $stderr = File.open(File::NULL, "w")
    example.run
    $stdout = saved_stdout
    $stderr = saved_stderr
  end

  DatabaseCleaner.strategy = :transaction
  config.around :example do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end
end
