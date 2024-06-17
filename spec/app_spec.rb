# spec/app_spec.rb
require 'spec_helper'

RSpec.describe 'Rodauth Password Expiration App' do

  let(:login) { 'user@example.com' }
  let(:password) { 'password' }

  describe 'Creating an account' do
    it 'creates a new account' do
      header 'Content-Type', 'application/json'
      post '/create-account', { login: login, password: password }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(200)
    end
  end

  # describe 'Logging in' do
  #   it 'logs in successfully' do
  #     header 'Content-Type', 'application/json'
  #     post '/create-account', { login: login, password: password }.to_json, { 'CONTENT_TYPE' => 'application/json' }

  #     header 'Content-Type', 'application/json'
  #     post '/login', { login: login, password: password }.to_json, { 'CONTENT_TYPE' => 'application/json' }
  #     expect(last_response.status).to eq(200)
  #   end

  #   it 'fails to log in with incorrect credentials' do
  #     header 'Content-Type', 'application/json'
  #     post '/create-account', { login: login, password: password }.to_json, { 'CONTENT_TYPE' => 'application/json' }

  #     header 'Content-Type', 'application/json'
  #     post '/login', { login: login, password: "wrongpassword" }.to_json, { 'CONTENT_TYPE' => 'application/json' }
  #     expect(last_response.status).to eq(401)
  #   end
  # end

  def changed_at
    # There should only be one account in the DB so we can just fetch its changed_at time
    change_times = DB[:account_password_change_times].all
    change_times.first[:changed_at] if change_times.any?
  end

  describe 'Changing Password' do
    it 'changes the password successfully' do
      header 'Content-Type', 'application/json'
      post '/login',  { login: login, password: password }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(200)
      auth_token = last_response.headers['Authorization'].split(' ').last

      before = changed_at
      puts("changed_at before change-password #{before}")

      sleep(1)

      header 'Authorization', "Bearer #{auth_token}"
      post '/change-password', { password: password, "new-password": 'newpassword' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(200)

      after = changed_at
      puts("changed_at after change-password #{after}")

      post '/login', { login: login, password: 'newpassword' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(200)
      expect(before).not_to eq(after)
    end
  end
end
