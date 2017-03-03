
require "spec_helper"

describe "USERS API::" , :type => :api do

  describe 'list all users' do
    let (:user) { FactoryGirl.create(:user) }
    let (:admin) { FactoryGirl.create(:user, :admin) }

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        get "/users"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'as an admin' do
      before do
        3.times do
          FactoryGirl.create(:user)
        end
        header 'User-Token', admin.user_tokens.first.token
        get "/users"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
      end

      it 'includes users' do
        expect(last_response.body).to include('users')
      end

      it 'returns all users' do
        expect(json['users'].count).to eq(User.count)
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/users"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/users"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/users"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'get user details' do
    let (:user) { FactoryGirl.create(:user) }
    let (:admin) { FactoryGirl.create(:user, :admin) }

    before do
      header 'User-Token', user.user_tokens.first.token
      get "/users/#{user.id}"
    end

    it 'responds succesfully', :show_in_doc do
      expect(last_response.status).to eq 200
    end

    it 'returns user details' do
      expect(json).to include('user')
    end

    context 'for a different user' do
      before do
        header 'User-Token', user.user_tokens.first.token
        other_user = FactoryGirl.create(:user)
        get "/users/#{other_user.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid id' do
      before do
        header 'User-Token', user.user_tokens.first.token
        get "/users/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        other_user = FactoryGirl.create(:user)
        get "/users/#{other_user.id}"
      end

      it 'responds succesfully' do
        expect(last_response.status).to eq 200
      end

      it 'returns user details' do
        expect(json).to include('user')
      end
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/users/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/users/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        user.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', user.user_tokens.first.token
        get "/users/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'find user by' do
    let (:user) { FactoryGirl.create(:user) }
    let (:admin) { FactoryGirl.create(:user, :admin) }

    context 'username' do
      before do
        get "/users/find/#{user.username}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
      end

      it 'returns user details' do
        expect(json).to include('user')
        expect(json['user']).to include 'id'
      end


      context 'with invalid username' do
        before do
          header 'User-Token', user.user_tokens.first.token
          get "/users/find/doesnot.exist"
        end

        it_behaves_like 'a not found request'
      end
    end

    context 'email address' do
      before do
        get "/users/find/#{user.email}"
      end

      it 'responds succesfully' do
        expect(last_response.status).to eq 200
      end

      it 'returns user details' do
        expect(json).to include('user')
        expect(json['user']).to include 'id'
      end


      context 'with invalid email' do
        before do
          header 'User-Token', user.user_tokens.first.token
          get "/users/find/doesnot.exist@email.com"
        end

        it_behaves_like 'a not found request'
      end
    end

  end

  describe 'check token status' do
    let (:user) { FactoryGirl.create(:user) }

    before do
      header 'User-Token', user.user_tokens.first.token
      get '/users/token/valid'
    end

    it 'responds succesfully', :show_in_doc do
      expect(last_response.status).to eq 200
    end

    it 'returns user token' do
      expect(json).to include('token')
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/users/valid-token"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/users/valid-token"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        user.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', user.user_tokens.first.token
        get "/users/valid-token"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'create new user' do
    let (:user) { FactoryGirl.create(:user) }
    let (:admin) { FactoryGirl.create(:user, :admin) }
    let (:user_params2) { FactoryGirl.build(:user) }
    let (:user_params) {{user: {first_name: user_params2.first_name,
                                 last_name: user_params2.last_name,
                                 password: '1234',
                                 password_confirmation: '1234',
                                 username: user_params2.username,
                                 email: user_params2.email}}}


    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds succesfully', :show_in_doc do
        post "/users/", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
      end


      it 'should create a new user' do
        post "/users/", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(json).to include('user')
      end

      context 'missing parameter' do
        it 'password should fail' do
          params = {user: user_params[:user].except(:password)}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'first_name should fail' do
          params = {user: user_params[:user].except(:first_name)}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'last_name should fail' do
          params = {user: user_params[:user].except(:last_name)}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'username should fail' do
          params = {user: user_params[:user].except(:username)}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'email should fail' do
          params = {user: user_params[:user].except(:email)}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'password confirmation should succeed' do
          params = {user: user_params[:user].except(:password_confirmation)}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end
      end

      context 'invalid parameter' do

        it 'invalid email should fail' do
          user_params[:user][:email] = 'Not a real email.com'
          params = {user: user_params[:user]}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'duplicated email should fail' do
          user_params[:user][:email] = User.last.email
          params = {user: user_params[:user]}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'duplicated username should fail' do
          user_params[:user][:username] = User.last.username
          params = {user: user_params[:user]}
          post "/users/", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

      end



    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/users/", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        post "/users/", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        post "/users/", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        post "/users/", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end


  end

  describe 'update existing user' do
    let (:user) { FactoryGirl.create(:user) }
    let (:admin) { FactoryGirl.create(:user, :admin) }
    let (:existing_user) { FactoryGirl.create(:user) }
    let (:user_params) {{user: {first_name: 'Tom',
                                last_name: 'Jones',
                                username: 'tom.jones@singing.com',
                                company: 'singing',
                                admin: true}}}


    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds succesfully', :show_in_doc do
        put "/users/#{existing_user.id}", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
      end


      it 'should create a new user' do
        put "/users/#{existing_user.id}", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(json).to include('user')
      end

      context 'updating parameter' do
        it 'password should fail' do
          params = {user:{password: 'NoBodyLikesCats'}}
          put "/users/#{existing_user.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'first_name should succeed' do
          params = {user: {first_name: 'billy'}}
          put "/users/#{existing_user.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end

        it 'last_name should succeed' do
          params = {user: {last_name: 'joel'}}
          put "/users/#{existing_user.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end

        it 'company should succeed' do
          params = {user: {company: 'rockin'}}
          put "/users/#{existing_user.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end

        it 'admin should succeed' do
          params = {user: {last_name: true}}
          put "/users/#{existing_user.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end

        it 'username should succeed' do
          params = {user: {username: 'billy.joel@rockin.com'}}
          put "/users/#{existing_user.id}", params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end


      end



    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        put "/users/#{existing_user.id}", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'with invalid id' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        put "/users/-1", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a not found request'
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        put "/users/#{existing_user.id}", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        put "/users/#{existing_user.id}", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        put "/users/#{existing_user.id}", user_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end


  end

  describe 'delete a user' do
    let (:user) { FactoryGirl.create(:user) }
    let (:admin) { FactoryGirl.create(:user, :admin) }

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        delete "/users/#{user.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid id' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/users/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        other_user = FactoryGirl.create(:user)
        delete "/users/#{other_user.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
      end

      it 'returns user details' do
        expect(json).to include('user')
      end
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        delete "/users/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        delete "/users/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        delete "/users/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'trigger password reset email' do

    let (:user) { FactoryGirl.create(:user) }

    context 'with valid username' do
      it 'responds succesfully', :show_in_doc do
        post '/users/reset-password', {user: {email: user.email}, 'redirect-to' => 'http://some.url/TOKEN'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include('success')
      end

      it 'causes email to be sent' do
        expect { post '/users/reset-password', {user: {email: user.email}, 'redirect-to' => 'http://some.url/TOKEN'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
            .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'with invalid username' do

      it 'responds not found' do
        post '/users/reset-password', {user: {username: 'doesnot.exist'}, 'redirect-to' => 'http://some.url/TOKEN'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq(404)
      end

      it 'returns an error' do
        post '/users/reset-password', {user: {username: 'doesnot.exist'}, 'redirect-to' => 'http://some.url/TOKEN'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(json).to include('error')
      end

      it 'does not cause email to be sent' do
        expect { post '/users/reset-password', {user: {username: 'doesnot.exist'}, 'redirect-to' => 'http://some.url/TOKEN'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
            .to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end



  end

  describe 'change user password' do

    let (:user) { FactoryGirl.create(:user) }

    context 'with valid username' do

      before do
        user.create_password_token(expiration: DateTime.now + 90.minutes)
        @token = user.password_token.token
      end

      context 'and token' do

        before do
          post "/users/#{user.id}/reset-password/#{@token}", {user: {password: 'NoOneLikesCats'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it 'responds succesfully', :show_in_doc do
          expect(last_response.status).to eq 200
          expect(json).to include('user')
        end
      end
    end

    context 'with invalid user' do

      before do
        post "/users/-1/reset-password/123456789", {user: {password: 'NoOneLikesCats'}, 'redirect-to' => 'http://some.url/TOKEN'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a not found request'
    end

    context 'with invalid token' do

      before do
        post "/users/#{user.id}/reset-password/321321321321", {user: {password: 'NoOneLikesCats'}, 'redirect-to' => 'http://some.url/TOKEN'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired token' do

      before do
        user.create_password_token(expiration: DateTime.now + 90.minutes)
        @token = user.password_token
        @token.update(expiration: DateTime.now - 1.day)
        post "/users/#{user.id}/reset-password/#{@token.token}", {user: {password: 'NoOneLikesCats'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

  end
end
