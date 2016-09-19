require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @normal_user = users(:normal)
    @admin_user = users(:admin)
  end

  test "should not get index with out token" do
    get '/users',
        params: {},
        headers: { 'X-Extra-Header' => '123' },
        as: :json
    assert_response :unauthorized
  end
end
