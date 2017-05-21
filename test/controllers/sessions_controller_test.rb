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
end
