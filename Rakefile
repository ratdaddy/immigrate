require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# RSpec::Core::RakeTask.new(:spec)
#
# task :default => :spec

require 'yaml'
require 'logger'
require 'active_record'

include ActiveRecord::Tasks

root = File.expand_path '../spec/dummy', __FILE__
DatabaseTasks.env = ENV['ENV'] || 'test'
DatabaseTasks.database_configuration = YAML.load(File.read(File.join(root, 'config/database.yml')))
DatabaseTasks.migrations_paths = [File.join(root, 'db/migrate')]

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
end

load 'active_record/railties/databases.rake'