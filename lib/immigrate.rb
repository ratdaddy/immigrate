require 'immigrate/version'
require 'immigrate/railtie'
require 'immigrate/schema_statements'
require 'immigrate/database'

module Immigrate
  def self.database
    @@database ||= Database.new
  end
end
