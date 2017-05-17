
require "spec_helper"

describe "EXECUTIONS API::" , :type => :api do

  let (:team) {FactoryGirl.create(:team, users_count: 0, projects_count: 0)}
  let (:project) { FactoryGirl.create(:project, results_range: 1..2) }
  let (:testcase) {project.testcases.first}
  let (:environment) {project.environments.first}
  let (:execution) {project.executions.first}
  let (:user) {FactoryGirl.create(:user)}
  let (:admin) {FactoryGirl.create(:user, :admin)}

  describe('get execution details') do

    let  (:path) {"/executions/#{execution.id}"}
    let  (:invalid_path) {"/executions/-1"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('execution')
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('execution')
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get testcase count') do

    let  (:path) {"/executions/#{execution.id}/testcase-count"}
    let  (:invalid_path) {"/executions/-1/testcase-count"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('testcases')
        expect(json['testcases']).to eq(project.testcases.count)
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('testcases')
        expect(json['testcases']).to eq(project.testcases.count)
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get environment count') do

    let  (:path) {"/executions/#{execution.id}/environment-count"}
    let  (:invalid_path) {"/executions/-1/environment-count"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('environments')
        expect(json['environments']).to eq(project.environments.count)
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('environments')
        expect(json['environments']).to eq(project.environments.count)
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get testcase summary') do

    let  (:path) {"/executions/#{execution.id}/testcase_summary"}
    let  (:invalid_path) {"/executions/-1/testcase_summary"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('summary')
        expect(json['summary'].count).to eq(project.testcases.count)
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('summary')
        expect(json['summary'].count).to eq(project.testcases.count)
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get environment summary') do

    let  (:path) {"/executions/#{execution.id}/environment_summary"}
    let  (:invalid_path) {"/executions/-1/environment_summary"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('summary')
        expect(json['summary'].count).to eq(project.environments.count)
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('summary')
        expect(json['summary'].count).to eq(project.environments.count)
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get testcase status') do

    context 'as json' do
      let  (:path) {"/executions/#{execution.id}/testcase_status"}
      let  (:invalid_path) {"/executions/-1/testcase_status"}

      context 'as a non-admin' do

        before do
          header 'User-Token', user.user_tokens.first.token
        end

        it 'returns succesfully if viewable', :show_in_doc do
          team.users << user
          team.projects << project
          get path
          expect(last_response.status).to eq 200
          expect(json).to include('execution')
          expect(json['execution']).to include('pass')
          expect(json['execution']).to include('fail')
          expect(json['execution']).to include('skip')
        end

        it 'returns error if not viewable' do
          get path
          expect(last_response.status).to eq 403
          expect(json).to include('error')
        end

      end

      context 'as an admin' do

        before do
          header 'User-Token', admin.user_tokens.first.token
        end

        it 'returns succesfully if even if not on team' do
          get path
          expect(last_response.status).to eq 200
          expect(json).to include('execution')
          expect(json['execution']).to include('pass')
          expect(json['execution']).to include('fail')
          expect(json['execution']).to include('skip')
        end

      end

      context 'with invalid execution id' do

        before do
          header 'User-Token', user.user_tokens.first.token
          get invalid_path
        end

        it_behaves_like 'a not found request'

      end

      context 'without user token' do
        before do
          header 'User-Token', nil
          get path
        end

        it_behaves_like 'an unauthenticated request'
      end

      context 'with expired user token' do
        before do
          admin.user_tokens.first.update(expires: DateTime.now - 1.day)
          header 'User-Token', admin.user_tokens.first.token
          get path
        end

        it_behaves_like 'an unauthenticated request'

      end

      context 'with invalid user token' do
        before do
          header 'User-Token', 'asdfasdfasdfasdf'
          get path
        end

        it_behaves_like 'an unauthenticated request'

      end
    end

    context 'as xlsx' do
      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable' do
        team.users << user
        team.projects << project
        get "/executions/#{execution.id}/testcase_status.xlsx"
        expect(last_response.status).to eq 200
        expect(json).to include('report')
      end

    end

  end

  describe('get testcase detail') do

    let  (:path) {"/executions/#{execution.id}/testcases/#{testcase.id}"}
    let  (:invalid_path) {"/executions/-1/testcases/#{testcase.id}"}
    let  (:invalid_path_tc) {"/executions/#{execution.id}/testcases/-1"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
        expect(json['testcase']).to include('automated_results')
        expect(json['testcase']).to include('manual_results')
        expect(json['testcase']['id']).to eq testcase.id
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
        expect(json['testcase']).to include('automated_results')
        expect(json['testcase']).to include('manual_results')
        expect(json['testcase']['id']).to eq testcase.id
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'with invalid testcase id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get invalid_path_tc
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get environment detail') do

    let  (:path) {"/executions/#{execution.id}/environments/#{environment.id}"}
    let  (:invalid_path) {"/executions/-1/environments/#{environment.id}"}
    let  (:invalid_path_env) {"/executions/#{execution.id}/environments/-1"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('environment')
        expect(json['environment']).to include('results')
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('environment')
        expect(json['environment']).to include('results')
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'with invalid environment id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get invalid_path_env
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get incomplete tests') do

    let  (:path) {"/executions/#{execution.id}/incomplete"}
    let  (:invalid_path) {"/executions/-1/incomplete"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable', :show_in_doc do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('incomplete')
      end

      it 'returns all tests if all incomplete' do
        project = FactoryGirl.create(:project)
        team.users << user
        team.projects << project
        get "/executions/#{project.executions.last.id}/incomplete"
        expect(last_response.status).to eq 200
        expect(json).to include('incomplete')
        expect(json['incomplete'].count).to eq project.testcases.count
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('incomplete')
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get next incomplete test') do
    let  (:project) {FactoryGirl.create(:project)}
    let  (:path) {"/executions/#{project.executions.last.id}/next_test"}
    let  (:invalid_path) {"/executions/-1/next_test"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'returns succesfully if viewable' do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
      end

      it 'returns a different test' do
        team.users << user
        team.projects << project
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
      end

      it 'accepts keyword to filter' do
        team.users << user
        team.projects << project
        keyword = project.keywords.first
        get path + "?keyword[]=#{keyword.keyword}"
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
        testcase = Testcase.find(json['testcase']['id'])
        expect(testcase.keywords).to include(keyword)
      end

      it 'accepts multiple keywords', :show_in_doc do
        team.users << user
        team.projects << project
        keyword = project.keywords.first
        second_keyword = project.keywords.last
        keyword.testcases.last.keywords << second_keyword
        get path + "?keyword[]=#{keyword.keyword}&keyword[]=#{second_keyword.keyword}"
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
        testcase = Testcase.find(json['testcase']['id'])
        expect(testcase.keywords).to include(keyword)
        expect(testcase.keywords).to include(second_keyword)
      end

      it 'returns blank if not test with keyword' do
        team.users << user
        team.projects << project
        keyword = project.keywords.last
        get path + "?keyword[]=#{keyword.keyword}"
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
        expect(json['testcase']).to include('No remaining testcases')
      end

      it 'return error with bad keyword' do
        team.users << user
        team.projects << project
        get path + "?keyword=NOTREAL"
        expect(last_response.status).to eq 404
        expect(json).to include('error')
      end

      it 'returns error if not viewable' do
        get path
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'returns succesfully if even if not on team' do
        get path
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', user.user_tokens.first.token
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe('get failing tests') do

    let  (:path) {"/executions/#{project.api_key}/failing"}
    let  (:invalid_path) {"/executions/-1/failing"}


    it 'returns succesfully if viewable', :show_in_doc do
      team.users << user
      team.projects << project
      get path
      expect(last_response.status).to eq 200
      expect(json).to include('failing')
      expect(json['failing'].count).to eq execution.results.where(current_status: 'fail').count
    end


    context 'with invalid execution id' do

      before do
        get invalid_path
      end

      it_behaves_like 'a not found request'

    end

  end

  describe('close execution') do

    context 'with project key' do

      it 'should close the last execution' do
        post 'executions/close', {project_key: project.api_key}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'execution'
        expect(Execution.find(execution.id).closed).to eq true
      end

      it 'should name the new execution', :show_in_doc do
        post 'executions/close', {project_key: project.api_key, name: 'Some Name'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'execution'
        expect(json['execution']['name']).to eq 'Some Name'
        expect(Execution.find(execution.id).closed).to eq true
        expect(Execution.last.name).to eq 'Some Name'
      end

      context 'with invalid project key' do
        before do
          post 'executions/close', {project_key: 'not a real key', name: 'Some Name'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'a not found request'

      end

      context 'with missing project key' do
        before do
          post 'executions/close', { name: 'Some Name'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'a bad request'

      end

    end

    context 'with execution id' do


      context 'as an admin' do
        before do
          header 'User-Token', admin.user_tokens.first.token
        end

        it 'should close the last execution' do
          post 'executions/close', {execution_id: execution.id}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include 'execution'
          expect(Execution.find(execution.id).closed).to eq true
        end

        it 'should name the new execution', :show_in_doc do
          post 'executions/close', {execution_id: execution.id, name: 'Some Name'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include 'execution'
          expect(json['execution']['name']).to eq 'Some Name'
          expect(Execution.find(execution.id).closed).to eq true
          expect(Execution.last.name).to eq 'Some Name'
        end

      end

      context 'as a non-admin' do
        context 'it should not allow if project is not viewable' do
           before do
            header 'User-Token', user.user_tokens.first.token
            post 'executions/close', {execution_id: execution.id}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
           end

           it_behaves_like 'a forbidden request'
        end

      end

      context 'with invalid execution id' do
        before do
          header 'User-Token', admin.user_tokens.first.token
          post 'executions/close', {execution_id: '-1', name: 'Some Name'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'a not found request'

      end

      context 'with missing project key' do
        before do
          header 'User-Token', admin.user_tokens.first.token
          post 'executions/close', {name: 'Some Name'}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'a bad request'

      end


    end
  end

  describe('delete an execution') do

    let  (:path) {"/executions/#{execution.id}"}
    let  (:invalid_path) {"/executions/-1"}

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
        delete path
      end

      it_behaves_like 'a forbidden request'
    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        delete path
      end

      it 'returns succesfully', :show_in_doc do

        expect(last_response.status).to eq 200
        expect(json).to include('execution')

      end

      it 'creates a new execution' do
        expect(project.executions.count).to eq 1
      end

    end

    context 'with invalid execution id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        delete invalid_path
      end

      it_behaves_like 'a not found request'

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        delete path
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        delete path
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        delete path
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

end