require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_path
    assert_response :success
  end

  test 'should show user' do
    user = users(:cthulhu)
    get user_path(user)
    assert_response :success
    assert_select 'title', full_title(user.name)
    assert_match "Role: <strong>#{user.role}</strong>", response.body
  end
end
