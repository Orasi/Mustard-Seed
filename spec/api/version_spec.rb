
require "spec_helper"

describe "Version API::" , :type => :api do

  describe 'version' do

    it 'responds successfully', :show_in_doc do
      get "/version/"
      expect(last_response.status).to eq 200
      expect(json).to include('version')
    end

  end

end
