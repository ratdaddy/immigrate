require 'immigrate/version'
require 'immigrate/railtie'
require 'immigrate/foreign_table_definition'
require 'immigrate/database'

module Immigrate
  def self.database
    @@database ||= Database.new
  end
end
