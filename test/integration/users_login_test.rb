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
    get root_or_admin_path
    assert flash.empty?

    # Check nav has right elements
    assert_select 'a[href=?]', login_path
  end

  test 'login with valid info' do
    get  login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'goofballgoofball' } }
    assert_redirected_to root_or_admin_url
    follow_redirect!

    assert_template 'static_pages/home'

    # Check nav has right elements
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', short_urls_path
    assert_select 'a[href=?]', user_path(@user)

    # Check we're seeing search and new short url button
    assert_select 'a[href=?]', new_short_url_path, class: 'button create_url', text: 'Create a Short URL'
    assert_select 'fieldset.short_url_search_form' 
  end

  test 'logout should work' do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'goofballgoofball' } }
    assert is_logged_in?

    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_or_admin_url
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path,     count: 0
    assert_select 'a[href=?]', users_path,      count: 0
    assert_select 'a[href=?]', short_urls_path, count: 0

    # simulate a second logout in a second browser window
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path,     count: 0
    assert_select 'a[href=?]', users_path,      count: 0
    assert_select 'a[href=?]', short_urls_path, count: 0
  end

  test 'memorious login' do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies['remember_token']
  end

  test 'forgetful login' do
    # Log in to set the cookie
    log_in_as(@user, remember_me: '1')

    # Log in again and test that the cookie is deleted
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
