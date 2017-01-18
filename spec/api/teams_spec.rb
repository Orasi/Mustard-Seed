
require "spec_helper"

describe "TEAMS API::" , :type => :api do

  let (:team) {FactoryGirl.create(:team)}
  let (:user) {team.users.first}
  let (:project) { team.projects.first }
  let (:admin) {FactoryGirl.create(:user, :admin)}

  describe 'list all teams' do

    context 'as a non-admin' do
      before do
        FactoryGirl.create(:team, users_count: 0)
        header 'User-Token', user.user_tokens.first.token
        get "/teams"
      end

      it 'responds successfully' do
        expect(last_response.status).to eq 200
      end

      it 'should return all users teams' do
        expect(json).to include('teams')
        expect(json['teams'].count).to eq user.teams.count
      end

      it 'does not return all teams' do
        expect(json).to include('teams')
        expect(json['teams'].count).to_not eq Team.count
      end

    end

    context 'as an admin' do
      before do
        3.times do
          FactoryGirl.create(:team)
        end

        header 'User-Token', admin.user_tokens.first.token
        get "/teams"
      end

      it 'responds successfully', :show_in_doc do
        expect(last_response.status).to eq 200
      end

      it 'should return all teams' do
        expect(json).to include('teams')
        expect(json['teams'].count).to eq Team.count
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/teams"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/teams"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/teams"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'get team details' do

    context 'with invalid team id' do
      before do
        header 'User-Token', user.user_tokens.first.token
        get "/teams/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do

      before do
        other_team = FactoryGirl.create(:team)
        header 'User-Token', admin.user_tokens.first.token
        get "/teams/#{other_team.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('team')
      end

      it 'should access any team regardless of team' do
        expect(last_response.status).to eq 200
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should be able to access team viewable by user' do
        get "/teams/#{team.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('team')
      end

      it 'should not be able to access team not viewable by user' do
        other_team = FactoryGirl.create(:team, users_count: 0)
        get "/teams/#{other_team.id}"
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/teams/#{team.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/teams/#{team.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/teams/#{team.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'create new team' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        post "/teams", {team: FactoryGirl.attributes_for(:team)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'team'
      end

      it 'should create team' do
        expect { post "/teams", {team: FactoryGirl.attributes_for(:team)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
            .to change { Team.count }.by(1)
      end

      context 'without' do

        it 'description should fail' do
          post "/teams", {team: FactoryGirl.attributes_for(:team, description: nil)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'name should fail' do
          post "/teams", {team: FactoryGirl.attributes_for(:team, name: nil)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

      end

    end

    context 'with duplicate name' do
      it 'should return an error' do
        header 'User-Token', admin.user_tokens.first.token
        post "/teams", {team: {name: team.name}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end

    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        post "/teams", FactoryGirl.attributes_for(:team).to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        post "/teams", FactoryGirl.attributes_for(:team).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        post "/teams", FactoryGirl.attributes_for(:team).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        post "/teams", FactoryGirl.attributes_for(:team).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'update existing team' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        put "/teams/#{team.id}", {team: {name: 'Some New Name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'team'
      end

      context 'should update' do
        it 'name' do
          team = FactoryGirl.create(:team)
          put "/teams/#{team.id}", {team: {name: 'New Name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(json['team']).to include 'name'
          expect(json['team']['name']).to eq ('New Name')
          expect(Team.last.name).to eq ('New Name')
        end

        it 'description' do
          team = FactoryGirl.create(:team)
          put "/teams/#{team.id}", {team: {description: 'Some new description'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(json['team']).to include 'description'
          expect(json['team']['description']).to eq ('Some new description')
          expect(Team.last.description).to eq ('Some new description')
        end

      end

    end

    context 'with invalid team id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        put "/teams/-1", FactoryGirl.attributes_for(:team).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a not found request'
    end

    context 'with duplicate name' do
      it 'should return an error' do
        name = FactoryGirl.create(:team).name
        header 'User-Token', admin.user_tokens.first.token
        post "/teams", {team: {name: name}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end
    end

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        put "/teams/#{team.id}", {team: {name: 'A New Name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a forbidden request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        put "/teams/#{team.id}", FactoryGirl.attributes_for(:team).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        put "/teams/#{team.id}", FactoryGirl.attributes_for(:team).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        put "/teams/#{team.id}", FactoryGirl.attributes_for(:team).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'delete existing team' do

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        delete "/teams/#{team.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid id' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/teams/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/teams/#{team.id}"
      end

      it 'responds succesfully' do
        expect(last_response.status).to eq 200
      end

      it 'returns user details', :show_in_doc do
        expect(json).to include('team')
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        delete "/teams/#{team.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        delete "/teams/#{team.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        delete "/teams/#{team.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'add user to team' do

    context 'as an admin' do

      before do
        other_team = FactoryGirl.create(:team)
        user = FactoryGirl.create(:user)
        @team_count = other_team.users.count
        header 'User-Token', admin.user_tokens.first.token
        post "/teams/#{other_team.id}/user/#{user.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('team')
      end

      it 'should add user to team' do
        expect(json).to include('team')
        expect(json['team']).to include('users')
        expect(json['team']['users'].count).to eq (@team_count +1)
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
        user = FactoryGirl.create(:user)
        post "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid team id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        user = FactoryGirl.create(:user)
        post "/teams/-1/user/#{user.id}"
      end


      it_behaves_like 'a not found request'
    end

    context 'with invalid user id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        user = FactoryGirl.create(:user)
        post "/teams/#{team.id}/user/-1"
      end


      it_behaves_like 'a not found request'
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        user = FactoryGirl.create(:user)
        post "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        user = FactoryGirl.create(:user)
        post "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        user = FactoryGirl.create(:user)
        post "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with user already on team' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        user = team.users.first
        post "/teams/#{team.id}/user/#{user.id}"
      end


      it_behaves_like 'a bad request'

    end


  end

  describe 'add project to team' do

    context 'as an admin' do

      before do
        other_team = FactoryGirl.create(:team)
        project = FactoryGirl.create(:project)
        @team_count = other_team.projects.count
        header 'User-Token', admin.user_tokens.first.token
        post "/teams/#{other_team.id}/project/#{project.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('team')
      end

      it 'should add user to team' do
        expect(json).to include('team')
        expect(json['team']).to include('projects')
        expect(json['team']['projects'].count).to eq (@team_count +1)
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
        project = FactoryGirl.create(:project)
        post "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid team id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        project = FactoryGirl.create(:project)
        post "/teams/-1/project/#{project.id}"
      end


      it_behaves_like 'a not found request'
    end

    context 'with invalid project id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        project = FactoryGirl.create(:project)
        post "/teams/#{team.id}/project/-1"
      end


      it_behaves_like 'a not found request'
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        project = FactoryGirl.create(:project)
        post "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        project = FactoryGirl.create(:project)
        post "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        project = FactoryGirl.create(:project)
        post "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with user already on team' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        project = team.projects.first
        post "/teams/#{team.id}/project/#{project.id}"
      end


      it_behaves_like 'a bad request'

    end


  end

  describe 'remove user from team' do

    context 'as an admin' do

      before do
        other_team = FactoryGirl.create(:team)
        user = other_team.users.first
        @team_count = other_team.users.count
        header 'User-Token', admin.user_tokens.first.token
        delete "/teams/#{other_team.id}/user/#{user.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('team')
      end

      it 'should add user to team' do
        expect(json).to include('team')
        expect(json['team']).to include('users')
        expect(json['team']['users'].count).to eq (@team_count -1)
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
        user = FactoryGirl.create(:user)
        delete "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid team id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        user = team.users.first
        delete "/teams/-1/user/#{user.id}"
      end


      it_behaves_like 'a not found request'
    end

    context 'with invalid user id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        user = team.users.first
        delete "/teams/#{team.id}/user/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        user = team.users.first
        delete "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        user = team.users.first
        delete "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        user = team.users.first
        delete "/teams/#{team.id}/user/#{user.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with user not on team' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        user = FactoryGirl.create(:user)
        delete "/teams/#{team.id}/user/#{user.id}"
      end


      it_behaves_like 'a bad request'

    end

  end

  describe 'remove project from team' do

    context 'as an admin' do

      before do
        other_team = FactoryGirl.create(:team)
        project = other_team.projects.first
        @team_count = other_team.projects.count
        header 'User-Token', admin.user_tokens.first.token
        delete "/teams/#{other_team.id}/project/#{project.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('team')
      end

      it 'should add user to team' do
        expect(json).to include('team')
        expect(json['team']).to include('projects')
        expect(json['team']['projects'].count).to eq (@team_count -1)
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
        project = team.projects.first
        delete "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid team id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        project = team.projects.first
        delete "/teams/-1/project/#{project.id}"
      end


      it_behaves_like 'a not found request'
    end

    context 'with invalid project id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        project = team.projects.first
        delete "/teams/#{team.id}/project/-1"
      end


      it_behaves_like 'a not found request'
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        project = team.projects.first
        delete "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        project = team.projects.first
        delete "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        project = team.projects.first
        delete "/teams/#{team.id}/project/#{project.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with project not on team' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        project = FactoryGirl.create(:project)
        delete "/teams/#{team.id}/project/#{project.id}"
      end


      it_behaves_like 'a bad request'

    end

  end


end
