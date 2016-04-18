require 'spec_helper'

module Immigrate
  describe SchemaStatements do
    describe '#create_foreign_connection' do
      it 'creates the fdw extension' do
        connection.create_foreign_connection :foreign_server

        expect(extension_check).to be_truthy
      end
    end

    describe '#drop_foreign_connection' do
      it 'drops the fdw extension' do
        connection.create_foreign_connection :foreign_server
        connection.drop_foreign_connection :foreign_server

        expect(extension_check).to be_falsey
      end
    end

    def connection
      Class.new { extend SchemaStatements }
    end

    def extension_check
      ActiveRecord::Base.connection
          .execute("SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'postgres_fdw'").count > 0
    end
  end
end
