
require "spec_helper"

describe "ENVIRONMENTS API::" , :type => :api do

  let (:project) { FactoryGirl.create(:project) }
  let (:environment) {project.environments.first}
  let (:user) {FactoryGirl.create(:user)}
  let (:admin) {FactoryGirl.create(:user, :admin)}


  describe 'get environment details' do



    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get "/environments/#{environment.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('environment')
      end

      it 'should access any environment regardless of environment' do
        expect(last_response.status).to eq 200
      end

    end


    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should be able to access environment viewable by user' do
        team = FactoryGirl.create(:team)
        team.users << user
        project = team.projects.first
        environment = project.environments.first
        get "/environments/#{environment.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('environment')
      end

      it 'should not be able to access environment not viewable by user' do
        get "/environments/#{environment.id}"
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end
    end

    context 'with invalid environment id' do
      before do
        header 'User-Token', user.user_tokens.first.token
        get "/environments/-1"
      end

      it_behaves_like 'a not found request'
    end


    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/environments/#{environment.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/environments/#{environment.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/environments/#{environment.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'create new environment' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully' do
        post "/environments", {environment: {uuid: 123456789, project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'environment'
      end

      it 'should create environment' do
        id = project.id
        expect { post "/environments", {environment: {uuid: 123456789, project_id: id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
            .to change { Environment.count }.by(1)
      end

      context 'without' do

        it 'uuid should fail' do
          post "/environments", {environment: { project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'name should fail' do
          post "/environments", {environment: { uuid: 12345678}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

      end

    end

    context 'with duplicate uuid' do
      it 'should return an error' do
        header 'User-Token', admin.user_tokens.first.token
        post "/environments", {environment: {uuid: environment.uuid, project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end

    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/environments", {environment: {uuid: environment.uuid, project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        post "/environments", {environment: {uuid: environment.uuid, project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        post "/environments", {environment: {uuid: environment.uuid, project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        post "/environments", {environment: {uuid: environment.uuid, project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'update existing environment' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        put "/environments/#{environment.id}", {environment: {uuid: '987654321', display_name: 'Some new display name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'environment'
      end

      context 'should update' do
        it 'uuid' do
          put "/environments/#{environment.id}", {environment: {uuid: '987654321'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(json['environment']).to include 'uuid'
          expect(json['environment']['uuid']).to eq ('987654321')
          expect(Environment.find(environment.id).uuid).to eq ('987654321')
        end

        it 'display_name' do
          put "/environments/#{environment.id}", {environment: {display_name: 'Some Nice Display Name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(json['environment']).to include 'display_name'
          expect(json['environment']['display_name']).to eq ('Some Nice Display Name')
          expect(Environment.find(environment.id).display_name).to eq ('Some Nice Display Name')
        end

        it 'project_id' do
          new_project = FactoryGirl.create(:project)
          put "/environments/#{environment.id}", {environment: {project_id: new_project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(json['environment']).to include 'project_id'
          expect(json['environment']['project_id']).to eq (new_project.id)
          expect(Environment.find(environment.id).project).to eq (new_project)
        end

      end

    end

    context 'with invalid environment id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        put "/environments/-1", {environment: {uuid: 13579}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a not found request'
    end

    context 'with duplicate uuid' do
      it 'should return an error' do
        other_environment = project.environments.last
        header 'User-Token', admin.user_tokens.first.token
        post "/environments", {environment: {uuid: other_environment.uuid}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end
    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        put "/environments/#{environment.id}", {environment: {uuid: 123456789}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        put "/environments/#{environment.id}", FactoryGirl.attributes_for(:environment).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        put "/environments/#{environment.id}", FactoryGirl.attributes_for(:environment).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        put "/environments/#{environment.id}", FactoryGirl.attributes_for(:environment).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'delete existing environment' do

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        delete "/environments/#{environment.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid id' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/environments/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/environments/#{environment.id}"
      end

      it 'responds succesfully' do
        expect(last_response.status).to eq 200
      end

      it 'returns environment details', :show_in_doc do
        expect(json).to include('environment')
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        delete "/environments/#{environment.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        delete "/environments/#{environment.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        delete "/environments/#{environment.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

end
