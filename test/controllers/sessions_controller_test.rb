require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user       = users(:yig)
    @admin      = users(:cthulhu)
    @other_user = users(:hastur)
  end

  test "should get new" do
    get login_path
    assert_response :success
  end

  test 'friendly forwarding works' do
    get edit_user_path(@user)                 # action protected for only logged in users
    assert_redirected_to login_url            # should be redirected to log in
    log_in_as(@user)                          # login
    assert_redirected_to edit_user_url(@user) # check we've been sent back to our original destination

    assert_not session[:forwarding_url]       # ensure this can only be used once
  end

  # So... this test being here tells you something about a bug I discovered, eh?
  # I was creating a non-JS logout form that still prompted for confiramtion, and the first pass
  # started deleting users because I had mistakenly sent delete requests in a form_for tag against @user
  # ... that wasn't so good.
  test 'logout should not delete user' do
    log_in_as(@user)
    assert_no_difference 'User.count' do
      delete logout_path
    end
  end
end
