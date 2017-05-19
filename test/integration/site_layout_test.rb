 require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'should have nav and links' do 
    get root_url
    assert_response :success
    assert_select 'title', 'Go.Bath Beta'
    assert_select 'nav'
    assert_select '#logo'
  end
end