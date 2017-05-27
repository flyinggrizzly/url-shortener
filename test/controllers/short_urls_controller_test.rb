require 'test_helper'

class ShortUrlsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    @short_url = short_urls(:example)
  end

  test 'admins can get index' do
    log_in_as(@admin)
    get short_urls_path
    assert_response :success
  end

  test 'admins can get show' do
    log_in_as(@admin)
    get short_url_path(@short_url)
    assert_response :success
  end

  test 'admins can get new' do
    log_in_as(@admin)
    get new_short_url_path
    assert_response :success
  end

  test 'admins can create short urls' do
    log_in_as(@admin)
    assert_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: { url_alias: 'foo',
                                                 redirect: 'http://www.google.com' } }
    end
  end

  test 'bad short url params are not saved and rerender form' do
    log_in_as(@admin)

    # For Create
    assert_no_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: { url_alias: ' ',
                                                   redirect: 'www.google,com' } }
    end
    assert_template 'short_urls/new'

    # For Update
    original_alias    = @short_url.url_alias
    original_redirect = @short_url.redirect
    patch short_url_path(@short_url), params: { short_url: { url_alias: '',
                                                             redirect: 'http://www.google,com' } }
    assert @short_url.url_alias == original_alias
    assert @short_url.redirect  == original_redirect
    assert_template 'short_urls/edit'
  end

  test 'admins can get edit' do
    log_in_as(@admin)
    get edit_short_url_path(@short_url)
    assert_response :success
  end

  test 'admins can patch update' do
    log_in_as(@admin)
    new_alias    = 'zomg'
    new_redirect = 'http://flyinggrizzly.io'
    patch short_url_path(@short_url), params: { short_url: { url_alias: new_alias,
                                                             redirect:  new_redirect } }
    assert @short_url.url_alias = new_alias
    assert @short_url.redirect  = new_redirect
  end

  test 'admins can get delete' do
  end

  test 'admins can destroy' do
  end

end
