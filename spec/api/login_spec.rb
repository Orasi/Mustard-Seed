
require "spec_helper"

describe "LOGIN API::" , :type => :api do

  let (:user) { FactoryGirl.create(:user) }

  describe 'login' do

    context 'with valid credentials' do

      context 'with username' do
        before do
          header 'User-Token', user.user_tokens.first.token
          post "/authenticate/", {username: user.username, password: 12345}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it 'responds successfully', :show_in_doc do
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end

        it 'includes user token' do
          expect(json['user']).to include('token')
        end

      end

      context 'with email address' do

        before do
          header 'User-Token', user.user_tokens.first.token
          post "/authenticate/", {username: user.email, password: 12345}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it 'responds successfully', :show_in_doc do
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end

        it 'includes user token' do
          expect(json['user']).to include('token')
        end

      end

    end

    context 'with invalid username' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/authenticate/", {username: 'user.username', password: 12345}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with invalid password' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/authenticate/", {username: user.username, password: 'NotMyPassword'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with out password' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/authenticate/", { password: 'NotMyPassword'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a bad request'
    end

    context 'with out password' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/authenticate/", {username: user.username}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a bad request'
    end
  end

end
