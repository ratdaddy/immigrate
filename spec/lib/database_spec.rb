require 'spec_helper'

module Immigrate
  describe Database do
    describe '.create_fdw_extension' do
      it 'creates the fdw extension' do
        subject.create_fdw_extension

        expect(subject.connection).to be_extension_enabled(:postgres_fdw),
            'expected postgres_fdw extension to be enabled'
      end
    end

    describe '.drop_fdw_extension' do
      it 'drops the fdw extension' do
        subject.create_fdw_extension
        subject.drop_fdw_extension

        expect(subject.connection).not_to be_extension_enabled(:postgres_fdw),
            'expected postgres_fdw extension to be disabled'
      end
    end

    describe '.create_server_connection' do
      before :each do
        allow(subject).to receive(:database_configuration).and_return(
            'test' => {
              'some_foreign_server' => {
                'host' => 'some_foreign_host',
                'port' => 'some_foreign_port',
                'dbname' => 'some_foreign_db'
            }})
        subject.create_fdw_extension
      end

      it 'creates a server connection with the correct options' do
        subject.create_server_connection :some_foreign_server

        server = foreign_server(:some_foreign_server)
        expect(server).not_to be_nil
        expect(server.count).to be(1), 'only one foreign server should be created'
        expect(server.first['srvoptions']).to(
          eq('{host=some_foreign_host,port=some_foreign_port,dbname=some_foreign_db}'))
      end

      def foreign_server server_name
        subject.execute "SELECT * FROM pg_catalog.pg_foreign_server WHERE srvname = '#{server_name}'"
      end
    end
  end
end
