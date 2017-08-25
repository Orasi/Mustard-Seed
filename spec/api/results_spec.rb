
require "spec_helper"

describe "RESULTS API::" , :type => :api do

  let (:team) {FactoryGirl.create(:team, projects_count: 0, users_count: 0)}
  let (:project) { FactoryGirl.create(:project, results_range: 1..3) }
  let (:environment) {project.environments.first}
  let (:testcase) {project.testcases.first}
  let (:execution) {project.executions.open_execution}
  let (:result) {testcase.results.first}
  let (:user) {FactoryGirl.create(:user)}
  let (:admin) {FactoryGirl.create(:user, :admin)}

  let (:manual_result_params) {{result: {status: ['pass', 'fail', 'skip'].sample,
                                  environment_id: environment.uuid,
                                  testcase_id: testcase.validation_id,
                                  result_type: 'manual',
                                  execution_id: execution.id,
                                  comment: 'Some new comment'}}}

  let (:automated_result_params) {{result: {status: ['pass', 'fail', 'skip'].sample,
                                         environment_id: environment.uuid,
                                         testcase_id: testcase.validation_id,
                                         result_type: 'automated',
                                         project_id: project.api_key,
                                         comment: 'Some new comment',
                                         stacktrace: Faker::Lorem.paragraph,
                                         screenshot: "data:image/png;base64,#{ Base64.encode64(File.read('spec/api/test.png'))}",
                                         link: Faker::Internet.url}}}


  describe 'get recent results' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        id = project.id
        get "/recent-results"
      end

      it 'should return latest 10 results', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('results')
        expect(json['results'].count).to eq 10
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should show no results if none visible' do
        get "/recent-results"
        expect(last_response.status).to eq 200
        expect(json).to include('results')
        expect(json['results'].count).to eq 0
      end

      it 'should show results for visible projects' do
        team.users << user
        team.projects << project
        get "/recent-results"
        expect(last_response.status).to eq 200
        expect(json).to include('results')
        expect(json['results'].count).to eq 10
      end

      it 'should not show results for visible projects' do
        team.users << user
        team.projects << project
        get "/recent-results"
        results = json['results']

        #Create new project with new results not visible to user
        FactoryGirl.create(:project)
        get "/recent-results"
        expect(json['results']).to eq results
      end


    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/recent-results"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/recent-results"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/recent-results"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'get results details' do

    context 'with invalid results id' do
      before do
        team.projects << project
        team.users << user
        header 'User-Token', user.user_tokens.first.token
        get "/results/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get "/results/#{result.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('result')
      end

      it 'should access any result regardless of team' do
        expect(last_response.status).to eq 200
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should be able to access environment viewable by user' do
        team.users << user
        team.projects << project
        get "/results/#{result.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('result')
      end

      it 'should not be able to access environment not viewable by user' do
        get "/results/#{result.id}"
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/results/#{result.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/results/#{result.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/results/#{result.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'get result screenshot' do

    context 'with invalid results id' do
      before do
        team.projects << project
        team.users << user
        header 'User-Token', user.user_tokens.first.token
        get "/results/-1/screenshot/1"
      end

      it_behaves_like 'a not found request'
    end

    context 'with invalid screenshot id' do
      before do
        team.projects << project
        team.users << user
        header 'User-Token', user.user_tokens.first.token
        get "/results/#{result.id}/screenshot/-11"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        post '/results', automated_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        screenshot_id = json['result']['results'][0]['screenshot_id']
        get "/results/#{result.id}/screenshot/#{screenshot_id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('screenshot')
      end

      it 'should access any result regardless of team' do
        expect(last_response.status).to eq 200
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should be able to access environment viewable by user' do
        team.users << user
        team.projects << project
        post '/results', automated_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        screenshot_id = json['result']['results'][0]['screenshot_id']
        get "/results/#{result.id}/screenshot/#{screenshot_id}"
        expect(last_response.status).to eq 200
        expect(json).to include('screenshot')
      end

      it 'should not be able to access environment not viewable by user' do
        post '/results', automated_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        screenshot_id = json['result']['results'][0]['screenshot_id']
        get "/results/#{result.id}/screenshot/#{screenshot_id}"
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end
    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/results/#{result.id}/screenshot/1"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/results/#{result.id}/screenshot/1"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/results/#{result.id}/screenshot/1"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'create new result' do

    context 'manual result' do

      context 'with existing result' do

        context 'as an admin' do

          before do
            header 'User-Token', admin.user_tokens.first.token
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          end

          it 'responds succesfully', :show_in_doc do
            expect(last_response.status).to eq 200
            expect(json).to include 'result'

          end

          it 'should append to existing result' do
            result_count = json['result']['results'].count
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(json['result']['results'].count).to eq(result_count + 1)
          end


          it 'should update current status of existing result' do
            status = (['pass', 'fail', 'skip'] - [json['result']['current_status']]).sample
            manual_result_params[:result][:status] = status
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(json['result']['current_status']).to eq(status)
          end

          it 'should mark creator of result' do
            expect(json['result']['results'][0]['created_by_name'].downcase.gsub(/\s+/, "")).to eq ("#{admin.first_name} #{admin.last_name}".gsub(/\s+/, "").downcase)
            expect(json['result']['results'][0]['created_by_id']).to eq (admin.id)
          end


        end

        context 'as non-admin' do

          before do
            header 'User-Token', user.user_tokens.first.token

          end

          it 'should create result if project is viewable' do
            team.users << user
            team.projects << project
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(last_response.status).to eq 200
            expect(json).to include 'result'

          end

          it 'should not create result if project is not viewable' do
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(last_response.status).to eq 403
            expect(json).to include 'error'
          end

        end

      end

      context 'with out existing result' do

        context 'as an admin' do

          before do
            @status = manual_result_params[:result][:status]
            manual_result_params[:result][:environment_id] = project.environments.last.id
            testcase.results.where(environment_id: -1).destroy_all
            header 'User-Token', admin.user_tokens.first.token
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          end

          it 'responds succesfully' do
            expect(last_response.status).to eq 200
            expect(json).to include 'result'

          end

          it 'should create new result' do
            expect(json['result']['results'].count).to eq(1)
          end

          it 'should set current status of new result' do
            expect(json['result']['current_status']).to eq(@status)
          end

          it 'should mark creator of result' do
            expect(json['result']['results'][0]['created_by_name']).to eq ("#{admin.first_name} #{admin.last_name}")
            expect(json['result']['results'][0]['created_by_id']).to eq (admin.id)
          end


        end

        context 'as non-admin' do

          before do
            header 'User-Token', user.user_tokens.first.token
            testcase.results.where(environment_id: environment.id).destroy_all

          end

          it 'should create result if project is viewable' do
            team.users << user
            team.projects << project
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(last_response.status).to eq 200
            expect(json).to include 'result'

          end

          it 'should not create result if project is not viewable' do
            post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(last_response.status).to eq 403
            expect(json).to include 'error'
          end

        end
      end


      context 'without user token' do
        before do
          header 'User-Token', nil
          post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'an unauthenticated request'
      end


      context 'with expired user token' do
        before do
          admin.user_tokens.first.update(expires: DateTime.now - 1.day)
          header 'User-Token', admin.user_tokens.first.token
          post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'an unauthenticated request'

      end

      context 'with invalid user token' do
        before do
          header 'User-Token', 'asdfasdfasdfasdf'
          post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'an unauthenticated request'

      end

      context 'without' do

        without = ['result_type', 'status', 'execution_id', 'environment_id', 'testcase_id']
        without.each do |w|
          context "#{w} should fail" do
            before do
              header 'User-Token', admin.user_tokens.first.token
              manual_result_params[:result][w.to_sym] = nil
              post '/results', manual_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            end

            it_behaves_like 'a bad request'
          end
        end

      end

    end

    context 'automated result' do

      context 'with existing result' do


          before do
            automated_result_params[:result][:comment] = 'Some New Comment'
            params = automated_result_params
            @result_count = testcase.results.where(environment_id: environment.id).first.results.count

            post '/results', params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          end

          it 'responds succesfully' do
            expect(last_response.status).to eq 200
            expect(json).to include 'result'

          end

          it 'should append to existing result' do
            expect(json['result']['results'].count).to eq(@result_count + 1)
          end


          it 'should update current status of existing result' do
            status = (['pass', 'fail', 'skip'] - [json['result']['current_status']]).sample
            automated_result_params[:result][:status] = status
            post '/results', automated_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(json).to include('result')
            expect(json['result']['current_status']).to eq(status)
          end

      end

      context 'with out existing result' do

        before do
          params = automated_result_params
          @status = automated_result_params[:result][:status]
          testcase.results.where(environment_id: environment.id).destroy_all
          post '/results', params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it 'responds succesfully' do
          expect(last_response.status).to eq 200
          expect(json).to include 'result'
        end

        it 'should create a new result' do
          expect(json['result']['results'].count).to eq(1)
        end


        it 'should update current status of existing result' do
          expect(json).to include('result')
          expect(json['result']['current_status']).to eq(@status)
        end

      end

      context 'without' do

        without = ['result_type', 'status', 'project_id', 'environment_id', 'testcase_id']
        without.each do |w|
          context "#{w} should fail" do
            before do
              automated_result_params[:result][w.to_sym] = nil
              post '/results', automated_result_params.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            end

            it_behaves_like 'a bad request'
          end
        end
        # it 'status should fail'
        #
        # it 'environment id should fail'
        #
        # it 'testcase id should fail'




      end

    end


  end


end
