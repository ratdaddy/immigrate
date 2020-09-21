module Immigrate
  class ForeignTableDefinition
    NATIVE_DATABASE_TYPES = {
      bigint:     'bigserial',
      string:      'character varying',
      binary:      'bytea',
      datetime:    'timestamp',
      bit_varying: 'bit varying',

      text:        'text',
      integer:     'integer',
      float:       'float',
      decimal:     'decimal',
      time:        'time',
      date:        'date',
      daterange:   'daterange',
      numrange:    'numrange',
      tsrange:     'tsrange',
      tstzrange:   'tstzrange',
      int4range:   'int4range',
      int8range:   'int8range',
      boolean:     'boolean',
      xml:         'xml',
      tsvector:    'tsvector',
      hstore:      'hstore',
      inet:        'inet',
      cidr:        'cidr',
      macaddr:     'macaddr',
      uuid:        'uuid',
      json:        'json',
      jsonb:       'jsonb',
      ltree:       'ltree',
      citext:      'citext',
      point:       'point',
      line:        'line',
      lseg:        'lseg',
      box:         'box',
      path:        'path',
      polygon:     'polygon',
      circle:      'circle',
      bit:         'bit',
      money:       'money',
    }

    attr_reader :database, :server, :name, :columns, :options
    delegate :type_to_sql, to: :database

    def initialize name, server, options
      @database = Immigrate.database
      @name = name
      @server = server
      @options = define_options!(options)
      @columns = []
    end

    def define_options!(options)
      opts = { schema_name: 'public', remote_table_name: '' }.merge(options)
      raise ArgumentError, 'Wrong value of options[:remote_table_name] - should be non-empty!' if opts[:remote_table_name].empty?
      opts
    end

    def column name, type
      @columns << [name, type]
    end

    # ToDo: use ColumnDefinition.new(name, type, {})
    NATIVE_DATABASE_TYPES.keys.each do |column_type|
      module_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{column_type} name
          column name, :#{column_type}
        end
      CODE
    end

    def sql
      "CREATE FOREIGN TABLE #{name} (#{column_definitions}) SERVER #{server} OPTIONS (schema_name '#{options[:schema_name]}', table_name '#{options[:remote_table_name]}');"
    end

    def column_definitions
      columns.map { |column| "#{column.first} #{type_to_sql(column.second)}"}.join(',')
    end

    def native_column_type type
      NATIVE_DATABASE_TYPES[type]
    end
  end
end
