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
        expect(server.count).to eq(1)
        expect(server.first['srvoptions']).to(
          eq('{host=some_foreign_host,port=some_foreign_port,dbname=some_foreign_db}'))
      end

      def foreign_server server_name
        subject.execute "SELECT * FROM pg_catalog.pg_foreign_server WHERE srvname = '#{server_name}'"
      end
    end

    describe '.create_user_mapping' do
      before :each do
        allow(subject).to receive(:database_configuration).and_return(
            'test' => {
              'some_foreign_server' => {
                'user' => 'some_foreign_user',
                'password' => 'some_foreign_password',
            }})
        subject.create_fdw_extension
        subject.create_server_connection :some_foreign_server
      end

      it 'creates a user mapping with the correct options' do
        subject.create_user_mapping :some_foreign_server

        mapping = user_mapping(:some_foreign_server)
        expect(mapping.count).to eq(1)
        expect(mapping.first['umoptions']).to eq("{user=some_foreign_user,password=some_foreign_password}")
      end
    end

    def user_mapping server_name
      subject.execute <<-SQL
        SELECT *
        FROM pg_user_mappings
        WHERE srvname = '#{server_name}' AND usename = '#{current_user}'
      SQL
    end

    def current_user
      subject.execute("SELECT CURRENT_USER").first['current_user']
    end
  end
end
