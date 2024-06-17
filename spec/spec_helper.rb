# spec/spec_helper.rb
require_relative '../app'
require 'rack/test'
require 'rspec'
require 'sequel'
require 'sequel/extensions/migration'

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    App
  end

  config.before(:suite) do
    DB = Sequel.connect("sqlite://test.db")
    DB[:account_password_change_times].truncate
    DB[:accounts].truncate

    # DB.timezone = :utc
    # Sequel.application_timezone = :local
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'migrations')
  end

  config.after(:suite) do
    DB.disconnect
  end
end
