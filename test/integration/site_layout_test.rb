 require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'should have nav and links' do 
    get root_url
    assert_response :success
    assert_select 'title', 'url shortener beta'
    assert_select 'nav'
    assert_select '#logo'
    assert_select 'a', 'Users'
    assert_select 'a', 'Redirects'
  end
end