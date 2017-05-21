require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin      = users(:cthulhu)
    @user       = users(:hastur)
    @other_user = users(:yig)
  end

  test "should get new" do
    log_in_as(@admin)
    get new_user_path
    assert_response :success
  end

  test 'should show user' do
    log_in_as(@admin)
    user = users(:cthulhu)
    get user_path(user)
    assert_response :success
    assert_select 'title', full_title(user.name)
    assert_match "Role: <strong>Admin</strong>", response.body
  end

  test 'should index users' do
    log_in_as(@admin)
    get users_path
    assert_response :success
    users.each do |user|
      assert_select "li#user-#{user.id}"
      assert_select 'h3', user.name
      assert_select 'h5', "Role: #{user_role(user)}"
    end
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user), params: { user: { name:  @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirected new when not logged in' do
    get new_user_path
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect create when not logged in' do
    post users_path, params: { user: { name:                  @user.name,
                                       email:                 @user.email,
                                       password:              'goofballgoofball',
                                       password_confirmation: 'goofballgoofball' } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect show when not logged in' do
    get user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@user)
    get edit_user_path(@other_user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when logged in as wrong user' do
    log_in_as(@user)
    patch user_path(@other_user), params: { user: { name: @user.name, 
                                                    email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
end
