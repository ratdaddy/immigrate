module Immigrate
  class ForeignTableDefinition
    def self.native_database_types
      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES
    end

    attr_reader :server, :name, :columns

    def initialize name, server
      @name = name
      @server = server
      @columns = []
    end

    def column name, type
      @columns << [name, type]
    end

#    def string name
#      column name, :string
#    end
    native_database_types.keys.each do |column_type|
      module_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{column_type} name
          column name, :#{column_type}
        end
      CODE
    end

    def sql
      "CREATE FOREIGN TABLE #{name} (#{column_definitions}) SERVER #{server}"
    end

    def column_definitions
      columns.map { |column| "#{column.first} #{native_column_type column.second}"}.join(',')
    end

    def native_column_type type
      self.class.native_database_types[type][:name]
    end
  end
end
