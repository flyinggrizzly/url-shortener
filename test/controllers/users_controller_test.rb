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
    assert_match "Role: <strong>Admin</strong>", response.body
  end

  test 'should index users' do
    get users_path
    assert_response :success
    users.each do |user|
      assert_select "li#user-#{user.id}"
      assert_select 'h3', user.name
      assert_select 'h5', "Role: #{user_role(user)}"
    end
  end
end
