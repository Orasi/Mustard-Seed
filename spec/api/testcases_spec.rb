
require "spec_helper"
require 'csv'

describe "TESTCASES API::" , :type => :api do

  let (:team) { FactoryGirl.create(:team) }
  let (:project) { team.projects.first }
  let (:testcase) { project.testcases.first }
  let (:user) { team.users.first }
  let (:admin) { FactoryGirl.create(:user, :admin) }


  describe 'get testcase details' do

    context 'with invalid testcase id' do
      before do
        header 'User-Token', user.user_tokens.first.token
        get "/testcases/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get "/testcases/#{testcase.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
      end

      it 'should be able to access outdated testcase' do
        testcase.update(outdated: true)
        get "/testcases/#{testcase.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should be able to access testcase viewable by user' do
        team = FactoryGirl.create(:team)
        team.users << user
        project = team.projects.first
        testcase = project.testcases.first
        get "/testcases/#{testcase.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
      end

      it 'should return other versions of test case' do
        put "/testcases/#{testcase.id}", {testcase: {name: 'Renamed Testcase',
                                                     project_id: project.id,
                                                     validation_id: rand(10000..99999),
                                                     reproduction_steps: [{step_number: 1,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence},
                                                                          {step_number: 2,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        get "/testcases/#{testcase.id}"
        expect(json['other_versions'].count).to eq testcase.version

      end

      it 'should not be able to access testcase not viewable by user' do
        testcase = FactoryGirl.create(:project).testcases.first
        get "/testcases/#{testcase.id}"
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end

      it 'should be able to access outdated testcase' do
        team = FactoryGirl.create(:team)
        team.users << user
        project = team.projects.first
        testcase = project.testcases.first
        testcase.update(outdated: true)
        get "/testcases/#{testcase.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('testcase')
      end
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/testcases/#{testcase.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/testcases/#{testcase.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/testcases/#{testcase.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'create new testcase' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        id = project.id
        @testcase_count = Testcase.count
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      end

      it 'responds successfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include 'testcase'
      end

      it 'should create testcase' do
        expect(Testcase.count).to eq @testcase_count + 1
      end

      it 'should add token' do
        expect(json).to include('testcase')
        expect(json['testcase']).to include('token')
      end

      it 'should be version 1' do
        expect(json).to include('testcase')
        expect(json['testcase']).to include('version')
        expect(json['testcase']['version']).to eq 1
      end

      context 'without' do

        it 'name should fail' do
          post "/testcases", {testcase: {project_id: project.id,
                                         validation_id: rand(10000..99999),
                                         reproduction_steps: [{step_number: 1,
                                                               action: Faker::Lorem.sentence,
                                                               result: Faker::Lorem.sentence},
                                                              {step_number: 2,
                                                               action: Faker::Lorem.sentence,
                                                               result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'project_id should fail' do
          post "/testcases", {testcase: {name: 'Some Other New Testcase Name',
                                         validation_id: rand(10000..99999),
                                         reproduction_steps: [{step_number: 1,
                                                               action: Faker::Lorem.sentence,
                                                               result: Faker::Lorem.sentence},
                                                              {step_number: 2,
                                                               action: Faker::Lorem.sentence,
                                                               result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

      end

    end

    context 'with duplicate name' do
      it 'should return an error' do
        header 'User-Token', admin.user_tokens.first.token
        post "/testcases", {testcase: {project_id: project.id,
                                       name: testcase.name,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }


        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end

    end

    it 'can associte keywords' do
        header 'User-Token', admin.user_tokens.first.token
        id = project.id
        @testcase_count = Testcase.count
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}, keywords: project.keywords.pluck(:id)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'testcase'
        expect(json['testcase']).to include 'id'
        expect(Testcase.find(json['testcase']['id']).keywords.count).to equal project.keywords.count
    end

    context 'with duplicate validation_id' do
      it 'should return an error' do
        header 'User-Token', admin.user_tokens.first.token
        post "/testcases", {testcase: {project_id: project.id,
                                       name: 'Crazy Testcase Name',
                                       validation_id: testcase.validation_id,
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }


        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end

    end

    context 'as a non-admin' do
      before do
        project_id = project.id
        header 'User-Token', user.user_tokens.first.token

      end

      it 'responds successfully', :show_in_doc do

        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: project.id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(last_response.status).to eq 200
        expect(json).to include 'testcase'
      end

      it 'should create testcase if project is viewable' do
        id = project.id
        testcase_count = Testcase.count
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(Testcase.count).to eq testcase_count + 1
      end

      it 'should not create testcase if project is not viewable' do
        id = FactoryGirl.create(:project).id
        testcase_count = Testcase.count
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(last_response.status).to eq 403
        expect(json).to include 'error'
        expect(Testcase.count).to eq testcase_count
      end

      it 'stores user who created testcase' do
        id = project.id
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(json).to include('testcase')
        expect(json['testcase']).to include('username')
        expect(json['testcase']['username']).to eq ("#{user.first_name} #{user.last_name}")

      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: project.id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: project.id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        post "/testcases", {testcase: {name: 'Some New Testcase',
                                       project_id: project.id,
                                       validation_id: rand(10000..99999),
                                       reproduction_steps: [{step_number: 1,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence},
                                                            {step_number: 2,
                                                             action: Faker::Lorem.sentence,
                                                             result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'update existing testcase' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        put "/testcases/#{testcase.id}", {testcase: {name: 'Renamed Testcase',
                                                     project_id: project.id,
                                                     validation_id: rand(10000..99999),
                                                     reproduction_steps: [{step_number: 1,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence},
                                                                          {step_number: 2,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it 'responds successfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include 'testcase'
      end

      it 'creates a new testcase if steps change' do
        expect(json).to include 'testcase'
        expect(json['testcase']).to include('id')
        expect(json['testcase']['id']).to_not eq testcase.id
        expect(json['testcase']['version']).to eq testcase.version + 1
      end

      it 'should not create a new testcase if steps do not change'do
        testcase = project.testcases.last
        put "/testcases/#{testcase.id}", {testcase: {name: 'Renamed Testcase',
                                                     validation_id: rand(10000..99999)}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(json).to include 'testcase'
        expect(json['testcase']).to include('id')
        expect(json['testcase']['id']).to eq testcase.id
        expect(json['testcase']['version']).to eq testcase.version
      end

      it 'should have the same token' do
        expect(json).to include 'testcase'
        expect(json['testcase']).to include('token')
        expect(json['testcase']['token']).to eq testcase.token
      end

      it 'should have set existing testcase to outdated' do
        expect(Testcase.unscope(:where).find(testcase.id).outdated).to eq true
      end


    end

    it 'can associate keywords' do
        header 'User-Token', admin.user_tokens.first.token
        testcase_id = project.testcases.last.id
        expect{
          put "/testcases/#{testcase_id}", {testcase: {name: 'Renamed Testcase'}, keywords: project.keywords.pluck(:id)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        }.to change{Testcase.find(testcase_id).keywords.count}.from(1).to(project.keywords.count)
        expect(last_response.status).to eq 200
        expect(json).to include 'testcase'
    end

    context 'with invalid testcase id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        put "/testcases/-1", {testcase: {uuid: 13579}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a not found request'
    end

    context 'with duplicate validation id' do
      it 'should return an error' do
        other_testcase = project.testcases.last
        header 'User-Token', admin.user_tokens.first.token
        put "/testcases/#{testcase.id}", {testcase: {validation_id: other_testcase.validation_id}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end
    end

    context 'with duplicate name' do
      it 'should return an error' do
        other_testcase = project.testcases.last
        header 'User-Token', admin.user_tokens.first.token
        put "/testcases/#{testcase.id}", {testcase: {name: other_testcase.name}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end
    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        put "/testcases/#{testcase.id}", {testcase: {name: 'Renamed Testcase',
                                                     project_id: project.id,
                                                     validation_id: rand(10000..99999),
                                                     reproduction_steps: [{step_number: 1,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence},
                                                                          {step_number: 2,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(last_response.status).to eq 200
        expect(json).to include 'testcase'
      end

      it 'should update testcase if project is viewable' do
        id = project.id

        put "/testcases/#{testcase.id}", {testcase: {name: 'Renamed Testcase',
                                                     project_id: id,
                                                     validation_id: rand(10000..99999),
                                                     reproduction_steps: [{step_number: 1,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence},
                                                                          {step_number: 2,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(json['testcase']['name']).to eq 'Renamed Testcase'
      end

      it 'should not update testcase if project is not viewable' do
        project = FactoryGirl.create(:project)
        testcase = project.testcases.first
        testcase_count = Testcase.count
        put "/testcases/#{testcase.id}", {testcase: {name: 'Renamed Testcase',
                                                     project_id: project.id,
                                                     validation_id: rand(10000..99999),
                                                     reproduction_steps: [{step_number: 1,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence},
                                                                          {step_number: 2,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(last_response.status).to eq 403
        expect(json).to include 'error'
        expect(Testcase.count).to eq testcase_count
      end

      it 'stores user who updated testcase' do
        id = project.id
        put "/testcases/#{testcase.id}", {testcase: {name: 'Renamed Testcase',
                                                     project_id: id,
                                                     validation_id: rand(10000..99999),
                                                     reproduction_steps: [{step_number: 1,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence},
                                                                          {step_number: 2,
                                                                           action: Faker::Lorem.sentence,
                                                                           result: Faker::Lorem.sentence}]}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(json).to include('testcase')
        expect(json['testcase']).to include('username')
        expect(json['testcase']['username']).to eq ("#{user.first_name} #{user.last_name}")

      end


    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        put "/testcases/#{testcase.id}", FactoryGirl.attributes_for(:testcase).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        put "/testcases/#{testcase.id}", FactoryGirl.attributes_for(:testcase).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        put "/testcases/#{testcase.id}", FactoryGirl.attributes_for(:testcase).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'delete existing testcase' do

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        delete "/testcases/#{testcase.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid id' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/testcases/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/testcases/#{testcase.id}"
      end

      it 'responds succesfully' do
        expect(last_response.status).to eq 200
      end

      it 'returns testcase details', :show_in_doc do
        expect(json).to include('testcase')
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        delete "/testcases/#{testcase.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        delete "/testcases/#{testcase.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        delete "/testcases/#{testcase.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'import testcases' do

    it 'should upload testcases' do

      testcases = project.testcases.select('name', 'validation_id', 'reproduction_steps')
      testcases.first.name = 'Some New Name'
      testcases.last.validation_id = nil

      header 'User-Token', admin.user_tokens.first.token
      post "/projects/#{project.id}/import", {json: testcases.to_json}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(last_response.status).to eq 200
      expect(json).to include('success')
      expect(json).to include('failure')

    end


    it 'should update testcases', :show_in_doc do

      testcases = project.testcases.select('name', 'validation_id', 'reproduction_steps')
      testcase_validation_id = testcases.first.validation_id
      testcases = JSON.parse(testcases.to_json)
      testcases.first['reproduction_steps'].first['action'] = "Some New Action"
      old_version = project.testcases.first.version

      header 'User-Token', admin.user_tokens.first.token
      post "/projects/#{project.id}/import", {update: 'true',json: testcases.to_json}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(last_response.status).to eq 200
      expect(json).to include('success')
      expect(json).to include('failure')
      expect( project.testcases.where(validation_id: testcase_validation_id).first['reproduction_steps'].first['action'] ).to eq('Some New Action')
      expect( project.testcases.where(validation_id: testcase_validation_id).first['version']).to eq(old_version + 1)

    end

    it 'should not update unchanged testcases' do

      testcases = project.testcases.select('name', 'validation_id', 'reproduction_steps')
      testcase_validation_id = testcases.first.validation_id
      testcases = JSON.parse(testcases.to_json)
      old_version = project.testcases.first.version

      header 'User-Token', admin.user_tokens.first.token
      post "/projects/#{project.id}/import", {update: 'true',json: testcases.to_json}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(last_response.status).to eq 200
      expect(json).to include('success')
      expect(json).to include('failure')
      expect( project.testcases.where(validation_id: testcase_validation_id).first['version']).to eq(old_version)

    end

    it 'should change name with out changing version' do

      testcases = project.testcases.select('name', 'validation_id', 'reproduction_steps')
      testcase_validation_id = testcases.first.validation_id
      testcases = JSON.parse(testcases.to_json)
      testcases.first['name'] = "Some New Name"
      # testcases.first['validation_id'] = 'Some New validation id'
      old_version = project.testcases.first.version

      header 'User-Token', admin.user_tokens.first.token
      post "/projects/#{project.id}/import", {update: 'true',json: testcases.to_json}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(last_response.status).to eq 200
      expect(json).to include('success')
      expect(json).to include('failure')
      expect( project.testcases.where(validation_id: testcase_validation_id).first['name'] ).to eq('Some New Name')
      expect( project.testcases.where(validation_id: testcase_validation_id).first['version']).to eq(old_version)


    end

    it 'should change validation id with out changing version' do

      testcases = project.testcases.select('name', 'validation_id', 'reproduction_steps')
      testcases = JSON.parse(testcases.to_json)
      testcases.first['validation_id'] = "abc123"
      # testcases.first['validation_id'] = 'Some New validation id'
      old_version = project.testcases.first.version

      header 'User-Token', admin.user_tokens.first.token
      post "/projects/#{project.id}/import", {update: 'true',json: testcases.to_json}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(last_response.status).to eq 200
      expect(json).to include('success')
      expect(json).to include('failure')
      expect( project.testcases.where(validation_id: "abc123").first['version']).to eq(old_version)

    end

  end

  describe 'export testcases' do
    context 'as an admin' do
      context 'as json' do
        before do
          header 'User-Token', admin.user_tokens.first.token
          get "/projects/#{project.id}/testcases/export"
        end

        it 'responds succesfully', :show_in_doc do
          expect(last_response.status).to eq 200
          expect(json).to include('testcases')
        end

      end
      if !ENV['CI']
        context 'as xlsx' do
        before do
          header 'User-Token', admin.user_tokens.first.token
          get "/projects/#{project.id}/testcases/export.xlsx"
        end

        it 'responds succesfully', :show_in_doc do
          expect(last_response.status).to eq 200
          expect(json).to include('report')
        end

      end
      end
    end

  end

end

