 require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'should have nav and links' do 
    get root_or_admin_url
    assert_response :success
    assert_select 'title', full_title
    assert_select 'nav'
    assert_select 'a#logo[href=?]', root_or_admin_url
    # other nav elements appear based on log in status, and are tested in users_login_test.rb
  end

  test 'login screen has right fields' do
    get login_path
    assert_select 'input[type=email]', count: 1
    assert_select 'input[type=password]', count: 1
    assert_select 'input[type=checkbox]', count: 1
    assert_select 'input[type=submit]', count: 1
  end
end