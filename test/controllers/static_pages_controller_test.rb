require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_or_admin_url
    assert_response :success
    assert_select 'title', full_title
  end
end
