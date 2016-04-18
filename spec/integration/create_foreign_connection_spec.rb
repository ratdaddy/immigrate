require 'spec_helper'
require 'active_record'

describe 'Foreign connection' do
  around :example do |example|
    Dir.chdir(dummy_root) do
      ActiveRecord::Tasks::DatabaseTasks.create Rails.configuration.database_configuration['test']
      example.run
      ActiveRecord::Tasks::DatabaseTasks.drop Rails.configuration.database_configuration['test']
    end
  end

  it 'is created by a migration' do
    output = `RAILS_ENV=test rake db:migrate 2>&1`
    expect($?.exitstatus).to eq(0), "rake db:migrate was unsuccessful, output:\n#{output}"

    expect(ActiveRecord::Base.connection.execute(extension_check).first['extname']).to eq('postgres_fdw')
  end

  it 'is reverted by a rollback' do
    `RAILS_ENV=test rake db:migrate 2>&1`
    output = `RAILS_ENV=test rake db:rollback 2>&1`
    expect($?.exitstatus).to eq(0), "rake db:migrate was unsuccessful, output:\n#{output}"

    expect(ActiveRecord::Base.connection.execute(extension_check).to_a).to be_empty
  end

  def extension_check
    "SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'postgres_fdw'"
  end
end
