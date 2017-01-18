
require "spec_helper"

describe "PROJECTS API::" , :type => :api do

  let (:team) {FactoryGirl.create(:team)}
  let (:user) {team.users.first}
  let (:project) { team.projects.first }
  let (:admin) {FactoryGirl.create(:user, :admin)}

  describe 'list all projects' do

    context 'as a non-admin' do
      before do
        FactoryGirl.create(:project)
        FactoryGirl.create(:team, users_count: 0).users << user
        header 'User-Token', user.user_tokens.first.token
        get "/projects"
      end

      it 'responds successfully' do
        expect(last_response.status).to eq 200
      end

      it 'should return all users projects' do
        expect(json).to include('projects')
        expect(json['projects'].count).to eq user.projects.count
      end

      it 'does not return all projects' do
        expect(json).to include('projects')
        expect(json['projects'].count).to_not eq Project.count
      end

      it 'does get project from multiple teams' do
        expect(json).to include('projects')
        expect(json['projects'].count).to be > team.projects.count
      end

    end

    context 'as an admin' do
      before do
        5.times do
          FactoryGirl.create(:project)
        end
        header 'User-Token', admin.user_tokens.first.token
        get "/projects"
      end

      it 'responds successfully', :show_in_doc do
        expect(last_response.status).to eq 200
      end

      it 'should return all projects' do
        expect(json).to include('projects')
        expect(json['projects'].count).to eq Project.count
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/projects"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/projects"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/projects"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'get project details' do

    context 'with invalid project id' do
      before do
        header 'User-Token', user.user_tokens.first.token
        get "/projects/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do

      before do
        other_project = FactoryGirl.create(:project)
        header 'User-Token', admin.user_tokens.first.token
        get "/projects/#{other_project.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('project')
      end

      it 'should have executions, testcases, and environments' do
        expect(json).to include('project')
        expect(json['project']).to include('executions')
        expect(json['project']).to include('testcases')
        expect(json['project']).to include('environments')
      end

      it 'should access any project regardless of team' do
        expect(last_response.status).to eq 200
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should be able to access project viewable by user' do
        get "/projects/#{project.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('project')
        expect(json['project']).to include('executions')
        expect(json['project']).to include('testcases')
        expect(json['project']).to include('environments')
      end

      it 'should not be able to access project not viewable by user' do
        other_project = FactoryGirl.create(:project)
        get "/projects/#{other_project.id}"
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/projects/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/projects/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/projects/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'create new project' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        post "/projects", {project: FactoryGirl.attributes_for(:project)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'project'
      end

      it 'should create project' do
        expect { post "/projects", {project: FactoryGirl.attributes_for(:project)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
            .to change { Project.count }.by(1)
      end

      context 'without' do
        context 'name' do
          it 'should fail' do
            post "/projects", {project: FactoryGirl.attributes_for(:project, name: nil)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(last_response.status).to eq 400
            expect(json).to include('error')
          end
        end

      end

    end

    context 'with duplicate name' do
      it 'should return an error' do
        header 'User-Token', admin.user_tokens.first.token
        post "/projects", {project: {name: project.name}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end

    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/projects", FactoryGirl.attributes_for(:project).to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        post "/projects", FactoryGirl.attributes_for(:project).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        post "/projects", FactoryGirl.attributes_for(:project).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        post "/projects", FactoryGirl.attributes_for(:project).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'update existing project' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        put "/projects/#{project.id}", {project: {name: 'Some New Name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'project'
      end

      it 'should update attributes' do
        project = FactoryGirl.create(:project)
        put "/projects/#{project.id}", {project: {name: 'New Name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(json['project']).to include 'project_name'
        expect(json['project']['project_name']).to eq ('New Name')
        expect(Project.last.name).to eq ('New Name')
      end

    end

    context 'with invalid project id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        put "/projects/-1", FactoryGirl.attributes_for(:project).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a not found request'
    end

    context 'with duplicate name' do
      it 'should return an error' do
        name = FactoryGirl.create(:project).name
        header 'User-Token', admin.user_tokens.first.token
        post "/projects", {project: {name: name}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end

    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        put "/projects/#{project.id}", {project: {name: 'A New Name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        put "/projects/#{project.id}", FactoryGirl.attributes_for(:project).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        put "/projects/#{project.id}", FactoryGirl.attributes_for(:project).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        put "/projects/#{project.id}", FactoryGirl.attributes_for(:project).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'delete existing project' do

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        delete "/projects/#{project.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid id' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/projects/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/projects/#{project.id}"
      end

      it 'responds succesfully' do
        expect(last_response.status).to eq 200
      end

      it 'returns user details', :show_in_doc do
        expect(json).to include('project')
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        delete "/projects/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        delete "/projects/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        delete "/projects/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

end
