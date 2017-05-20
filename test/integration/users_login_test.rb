require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:yig)
  end

  test 'login with invalid info' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: '', password: '' } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?

    # Check nav has right elements
    assert_select 'a[href=?]', login_path
  end

  test 'login with valid info' do
    get  login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'goofballgoofball' } }
    assert_redirected_to root_url
    follow_redirect!

    assert_template 'static_pages/home'

    # Check nav has right elements
    assert_select 'a[href=?]', logout_path
    # assert_select 'a[href=?]', aliases_path
    assert_select 'a[href=?]', users_path
  end

  test 'logout should work' do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'goofballgoofball' } }
    assert is_logged_in?
    
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path,   count: 0
    assert_select 'a[href=?]', users_path,    count: 0
    # assert_select 'a[href=?]', aliases_path,  count: 0
  end
end
