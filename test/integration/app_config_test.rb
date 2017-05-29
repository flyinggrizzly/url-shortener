require 'test_helper'

class AppConfigTest < ActionDispatch::IntegrationTest
  test 'app name can be changed' do
    UrlGrey::Application.config.application_name = 'foobar'
    assert_equal 'foobar', full_title
  end

  test 'root is not redirected when redirect not enabled' do
    # test env - root redirect should not be enabled
    # ensures we don't end up with mayhem in the test environment
    Rails.env = 'test'
    assert Rails.env.test?
    UrlGrey::Application.config.root_redirect_enabled = false
    get root_or_admin_url
    assert_template 'static_pages/home'

    # Production - root redirect not enabled
    Rails.env = 'production'
    assert Rails.env.production?
    UrlGrey::Application.config.root_redirect_enabled = false
    get root_or_admin_url
    assert_template 'static_pages/home'
  end

  test 'root is redirected in prod when enabled' do
    Rails.env = 'production'
    assert Rails.env.production?
    UrlGrey::Application.config.root_redirect_enabled = true
    UrlGrey::Application.config.root_redirect_url = 'http://www.google.com'
    # get root_or_admin_url
    get '/'
    assert_redirected_to 'http://www.google.com'
  end
end
