# Immigrate

[![Build Status](https://travis-ci.org/ratdaddy/immigrate.svg?branch=master)](https://travis-ci.org/ratdaddy/immigrate)
[![Code Climate](https://codeclimate.com/github/ratdaddy/immigrate/badges/gpa.svg)](https://codeclimate.com/github/ratdaddy/immigrate)

Immigrate adds methods to `ActiveRecord::Migration` to create and manage [foreign-data wrappers](http://www.postgresql.org/docs/current/static/postgres-fdw.html) in PostgreSQL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'immigrate'
```

And then execute:

    $ bundle install

## Usage

### Connecting to a Remote Server

You will need to have a connection to a remote server before you can create a foreign table. This connection has to be created with connection information and user credentials for the foreign server in a `config/immigrate.yml` file:

```yaml
development:
  foreign_server:
    host: 192.83.123.89
    port: 5432
    dbname: foreign_db
    user: foreign_user
    password: password

production:
  foreign_server:
    host: 192.83.123.90
    port: 5432
    dbname: foreign_db
    user: foreign_user
    password: password
```

Next you will need to create a migration to create the connection using a standard migration file like `db/migrate/[TIMESTAMP]_create_foreign_connection.rb:

```ruby
class CreateForeignConnection < ActiveRecord::Migration[5.0]
  def change
    create_foreign_connection :foreign_server
  end
end
```

Then you can run the migration as usual:

```sh
$ rake db:migrate
```

Once you have a foreign connection you can now create migrations for the foreign tables you need to access in your application. This also goes in a standard migration file:

```ruby
class CreatePost < ActiveRecord::Migration[5.0]
  def change
    create_foreign_table :posts do |t|
      t.string :title
      t.text :body
    end
  end
end
```

And once again you can run your migrations as usual:

```sh
$ rake db:migrate
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Before run rspec first time:

```sh
$ ENV=test rake db:create
``` 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ratdaddy/immigrate. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

