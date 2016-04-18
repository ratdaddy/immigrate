require 'immigrate/version'
require 'immigrate/railtie'
require 'immigrate/schema_statements'
require 'immigrate/command_recorder'

module Immigrate
  def self.load
    ActiveRecord::ConnectionAdapters::AbstractAdapter.include Immigrate::SchemaStatements
    ActiveRecord::Migration::CommandRecorder.include Immigrate::CommandRecorder
  end
end
