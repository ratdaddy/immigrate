$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'immigrate'

def dummy_root
  File.expand_path('../dummy', __FILE__)
end

ENV['RAILS_ENV'] = 'test'
Dir.chdir(dummy_root) do
  require "#{dummy_root}/config/environment"
end
