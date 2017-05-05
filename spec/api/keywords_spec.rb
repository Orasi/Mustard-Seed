
require "spec_helper"

describe "KEYWORDS API::" , :type => :api do

  let (:team) { FactoryGirl.create(:team) }
  let (:project) { team.projects.first }
  let (:other_project) { FactoryGirl.create(:project)}
  let (:user) { team.users.first }
  let (:keyword) {project.keywords.first}
  let (:admin) {FactoryGirl.create(:user, :admin)}


  describe 'get keyword details' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get "/keywords/#{keyword.id}"
      end

      it 'responds succesfully', :show_in_doc do
        expect(last_response.status).to eq 200
        expect(json).to include('keyword')
      end

      it 'should access any keyword regardless of keyword' do
        expect(last_response.status).to eq 200
      end

    end

    context 'as a non-admin' do

      before do
        header 'User-Token', user.user_tokens.first.token
      end

      it 'should be able to access keyword viewable by user' do
        get "/keywords/#{keyword.id}"
        expect(last_response.status).to eq 200
        expect(json).to include('keyword')
      end

      it 'should not be able to access keyword not viewable by user' do
        project = FactoryGirl.create(:project)
        keyword = project.keywords.first
        get "/keywords/#{keyword.id}"
        expect(last_response.status).to eq 403
        expect(json).to include('error')
      end
    end

    context 'with invalid keyword id' do
      before do
        header 'User-Token', user.user_tokens.first.token
        get "/keywords/-1"
      end

      it_behaves_like 'a not found request'
    end


    context 'without user token' do
      before do
        header 'User-Token', nil
        get "/keywords/#{keyword.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        get "/keywords/#{keyword.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        get "/keywords/#{keyword.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

  end

  describe 'create new keyword' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        post "/keywords", {keyword: {keyword: 'AWESOME', project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'keyword'
      end

      it 'should create keyword' do
        id = project.id
        expect { post "/keywords", {keyword: {keyword: 'AWESOME', project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
            .to change { Keyword.count }.by(1)
      end

      it 'can associate testcases' do
        id = project.id
        expect { post "/keywords", {keyword: {keyword: 'AWESOME', project_id: project.id}, testcases: project.testcases.pluck(:id)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
            .to change { project.testcases.last.keywords.count }.by(1)
      end

      context 'without' do

        it 'keyword should fail' do
          post "/keywords", {keyword: { project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

        it 'project_id should fail' do
          post "/keywords", {keyword: { keyword: 12345678}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 400
          expect(json).to include('error')
        end

      end

    end

    context 'with duplicate keyword' do
      it 'should return an error' do
        header 'User-Token', admin.user_tokens.first.token
        post "/keywords", {keyword: {keyword: keyword.keyword, project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end

    end

    context 'as a non-admin' do

      context 'with view permission' do
        before do
          header 'User-Token', user.user_tokens.first.token
          post "/keywords", {keyword: {keyword: 'AWESOME', project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it 'responds successfully' do

          expect(last_response.status).to eq 200
          expect(json).to include 'keyword'
        end

        it 'should create keyword' do
          id = project.id
          expect { post "/keywords", {keyword: {keyword: 'AWESOME2', project_id: id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
              .to change { Keyword.count }.by(1)
        end
      end

      context 'with out view permission' do

        before do
          header 'User-Token', user.user_tokens.first.token
          post "/keywords", {keyword: {keyword: 'AWESOME', project_id: other_project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'a forbidden request'


      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        post "/keywords", {keyword: {keyword: 'AWESOME', project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        post "/keywords", {keyword: {keyword: 'AWESOME', project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        post "/keywords", {keyword: {keyword: 'AWESOME', project_id: project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'update existing keyword' do

    context 'as an admin' do

      before do
        header 'User-Token', admin.user_tokens.first.token
      end

      it 'responds successfully', :show_in_doc do
        put "/keywords/#{keyword.id}", {keyword: {keyword: 'MORE AWESOME'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'keyword'
      end

      it 'can associate testcases' do
        put "/keywords/#{project.keywords.last.id}", {keyword: {keyword: 'MORE AWESOME'}, testcases: project.testcases.pluck(:id)}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(json).to include 'keyword'
        expect(json['keyword']).to include 'testcase_count'
        expect(json['keyword']['testcase_count']).to equal project.testcases.count
      end

      context 'should update' do
        it 'keyword' do
          put "/keywords/#{keyword.id}", {keyword: {keyword: 'MORE AWESOME'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(json['keyword']).to include 'keyword'
          expect(json['keyword']['keyword']).to eq ('MORE AWESOME')
          expect(Keyword.find(keyword.id).keyword).to eq ('MORE AWESOME')
        end

        it 'project_id' do
          new_project = FactoryGirl.create(:project)
          put "/keywords/#{keyword.id}", {keyword: {project_id: new_project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(json['keyword']).to include 'project_id'
          expect(json['keyword']['project_id']).to eq (new_project.id)
          expect(Keyword.find(keyword.id).project).to eq (new_project)
        end

      end

    end

    context 'with invalid keyword id' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        put "/keywords/-1", {keyword: {keyword: 13579}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'a not found request'
    end

    context 'with duplicate keyword' do
      it 'should return an error' do
        other_keyword = project.keywords.last
        header 'User-Token', admin.user_tokens.first.token
        post "/keywords", {keyword: {keyword: other_keyword.keyword}}.to_json , { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
        expect(json).to include 'error'
      end
    end

    context 'as a non-admin' do

      context 'with view permission' do

        before do
          header 'User-Token', user.user_tokens.first.token
          put "/keywords/#{keyword.id}", {keyword: {keyword: 123456789}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it 'responds successfully', :show_in_doc do
          put "/keywords/#{keyword.id}", {keyword: {keyword: '987654321', display_name: 'Some new display name'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
          expect(last_response.status).to eq 200
          expect(json).to include 'keyword'
        end

        context 'should update' do
          it 'keyword' do
            put "/keywords/#{keyword.id}", {keyword: {keyword: '987654321'}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(json['keyword']).to include 'keyword'
            expect(json['keyword']['keyword']).to eq ('987654321')
            expect(Keyword.find(keyword.id).keyword).to eq ('987654321')
          end


          it 'project_id' do
            new_project = FactoryGirl.create(:project)
            put "/keywords/#{keyword.id}", {keyword: {project_id: new_project.id}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
            expect(json['keyword']).to include 'project_id'
            expect(json['keyword']['project_id']).to eq (new_project.id)
            expect(Keyword.find(keyword.id).project).to eq (new_project)
          end

        end
      end

      context 'with out view permission' do

        before do
          header 'User-Token', user.user_tokens.first.token
          put "/keywords/#{other_project.keywords.first.id}", {keyword: {keyword: 123456789}}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        end

        it_behaves_like 'a forbidden request'

      end


    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        put "/keywords/#{keyword.id}", FactoryGirl.attributes_for(:keyword).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        put "/keywords/#{keyword.id}", FactoryGirl.attributes_for(:keyword).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        put "/keywords/#{keyword.id}", FactoryGirl.attributes_for(:keyword).to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

  describe 'delete existing keyword' do

    context 'as a non-admin' do
      before do
        header 'User-Token', user.user_tokens.first.token
        delete "/keywords/#{keyword.id}"
      end

      it_behaves_like 'a forbidden request'
    end

    context 'with invalid id' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/keywords/-1"
      end

      it_behaves_like 'a not found request'
    end

    context 'as an admin' do
      before do
        header 'User-Token', admin.user_tokens.first.token
        delete "/keywords/#{keyword.id}"
      end

      it 'responds succesfully' do
        expect(last_response.status).to eq 200
      end

      it 'returns keyword details', :show_in_doc do
        expect(json).to include('keyword')
      end

    end

    context 'without user token' do
      before do
        header 'User-Token', nil
        delete "/keywords/#{keyword.id}"
      end

      it_behaves_like 'an unauthenticated request'
    end

    context 'with expired user token' do
      before do
        admin.user_tokens.first.update(expires: DateTime.now - 1.day)
        header 'User-Token', admin.user_tokens.first.token
        delete "/keywords/#{keyword.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end

    context 'with invalid user token' do
      before do
        header 'User-Token', 'asdfasdfasdfasdf'
        delete "/keywords/#{keyword.id}"
      end

      it_behaves_like 'an unauthenticated request'

    end
  end

end
