require 'immigrate/schema_statements'
require 'immigrate/command_recorder'

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  include Immigrate::SchemaStatements
end

class ActiveRecord::Migration::CommandRecorder
  include Immigrate::CommandRecorder
end
