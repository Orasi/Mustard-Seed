
require "spec_helper"

describe "DOWNLOADS API::" , :type => :api do

  let (:project) { FactoryGirl.create(:project) }
  let (:testcase) {project.testcases.first}
  let (:user) {FactoryGirl.create(:user)}
  let (:admin) {FactoryGirl.create(:user, :admin)}



  describe 'download' do

    context 'with valid token' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get "/projects/#{project.id}/testcases/export.xlsx"
      end

      it 'responds succesfully' do
        get json['report']
        expect(last_response.status).to eq 200
      end


    end

    context 'with invalid token' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get "/projects/#{project.id}/testcases/export.xlsx"
      end

      it 'returns an error' do
        get json['report'] + 'asdfasd'
        expect(last_response.status).to eq 404
        expect(json).to include('error')
      end


    end

    context 'with expired token' do

      before do
        header 'User-Token', admin.user_tokens.first.token
        get "/projects/#{project.id}/testcases/export.xlsx"
      end

      it 'returns an error' do
        DownloadToken.last.update(expiration: DateTime.now - 1.day)
        get json['report']
        expect(last_response.status).to eq 401
        expect(json).to include('error')
      end


    end

  end

end

