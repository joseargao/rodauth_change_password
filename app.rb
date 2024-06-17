# app.rb
require "roda"
require "rodauth"
require "sequel"
require "securerandom"
require "jwt"

SECRET_KEY = SecureRandom.hex(64)
DB = Sequel.connect("sqlite://test.db")

class App < Roda

  plugin :json_parser
  plugin :common_logger

  plugin :rodauth, json: :only do
    db DB
    enable :login, :logout, :create_account, :change_password, :password_expiration, :jwt
    account_password_hash_column :password_hash
    password_expiration_id_column :account_id
    password_expiration_changed_at_column :changed_at
    require_password_change_after 864000
    require_login_confirmation? false
    require_password_confirmation? false
    only_json? true
    jwt_secret SECRET_KEY
  end

  route do |r|
    r.rodauth

    r.root do
      { message: "Rodauth Sample" }
    end
  end

  def rodauth_session
    super.merge(jwt: JWT.encode({ account_id: rodauth.session_value }, SECRET_KEY, 'HS256'))
  end
end
