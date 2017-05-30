require 'test_helper'

class AppConfigTest < ActionDispatch::IntegrationTest
  test 'app name can be changed' do
    UrlGrey::Application.config.application_name = 'foobar'
    assert_equal 'foobar', full_title
  end

  test 'root is not redirected when not enabled' do
    UrlGrey::Application.config.root_redirect_enabled = false
    get root_url # because root_or_admin_url will bypass the redirection on its own
    assert_template 'static_pages/home'
  end

  test 'root is not redirected when enabled but no root short url present' do
    UrlGrey::Application.config.root_redirect_enabled = true
    get root_url # because root_or_admin_url will bypass the redirection on its own
    assert_template 'static_pages/home'
  end

  test 'root is not redirect when root short url present but not enabled' do
    UrlGrey::Application.config.root_redirect_enabled = false
    @root_short_url = ShortUrl.new(slug: 'root', redirect: 'http://redirect-root-to-me.com')
    @root_short_url.save
    get root_url # because root_or_admin_url will bypass the redirection on its own
    assert_template 'static_pages/home'
  end

  test 'root is redirected when enabled and root short url present' do
    @root_short_url = ShortUrl.new(slug: 'root', redirect: 'http://redirect-root-to-me.com')
    @root_short_url.save

    UrlGrey::Application.config.root_redirect_enabled = true
    get root_url # because root_or_admin_url will bypass the redirection on its own
    assert_redirected_to @root_short_url.reload.redirect
  end
end
