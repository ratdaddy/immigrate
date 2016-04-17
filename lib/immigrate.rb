require 'immigrate/version'
require 'immigrate/railtie'
require 'immigrate/schema_statements'

module Immigrate
  def self.load
    ActiveRecord::ConnectionAdapters::AbstractAdapter.include Immigrate::SchemaStatements
  end
end
