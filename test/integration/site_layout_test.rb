 require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'should have nav and links' do 
    get root_url
    assert_response :success
    assert_select 'title', full_title
    assert_select 'nav'
    assert_select 'a#logo[href=?]', root_url
    # other nav elements appear based on log in status, and are tested in users_login_test.rb
  end
end