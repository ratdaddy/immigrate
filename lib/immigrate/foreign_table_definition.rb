module Immigrate
  class ForeignTableDefinition
    attr_reader :server, :name, :columns

    def initialize name, server
      @name = name
      @server = server
      @columns = []
    end

    def string name
      @columns << [name, :string]
    end

    def sql
      "CREATE FOREIGN TABLE #{name} () SERVER #{server}"
    end
  end
end
