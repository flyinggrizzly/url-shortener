require 'test_helper'

class UserDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    @user  = users(:yig)
  end

  test 'delete page is available to admins' do
    log_in_as(@admin)
    get delete_user_path(@user)
    assert_response :success
    assert_template 'users/delete'
    assert_select 'h1', "Delete #{@user.name}"
    assert_select 'form input[type=submit][value="Destroy"]'
  end

  test 'delete page should only be available to admins' do
    log_in_as(@user)
    get delete_user_path(@admin)
    assert_redirected_to root_url
  end
end
