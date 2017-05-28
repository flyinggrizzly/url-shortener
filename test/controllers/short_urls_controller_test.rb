require 'test_helper'

class ShortUrlsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    @user  = users(:yig)
    @short_url = short_urls(:example)
  end

  test 'admins can get index' do
    log_in_as(@admin)
    get short_urls_path
    assert_response :success
  end

  test 'normal users cannot get index' do
    log_in_as(@user)
    get short_urls_path
    assert_redirected_to root_url
  end

  test 'admins can get show' do
    log_in_as(@admin)
    get short_url_path(@short_url)
    assert_response :success
  end

  test 'normal users cannot get show' do
    log_in_as(@user)
    get short_url_path(@short_url)
    assert_redirected_to root_url
  end

  test 'admins can get new' do
    log_in_as(@admin)
    get new_short_url_path
    assert_response :success
  end

  test 'normal users cannot get new' do
    log_in_as(@user)
    get new_short_url_path
    assert_redirected_to root_url
  end

  test 'admins can create short urls' do
    log_in_as(@admin)
    assert_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: { slug: 'foo',
                                                 redirect: 'http://www.google.com' } }
    end
  end

  test 'normal users cannot create short urls' do
    log_in_as(@user)
    assert_no_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: { slug: 'foo',
                                                   redirect:  'http://www.google.com' } }
    end
    assert_redirected_to root_url
  end

  test 'bad short url params are not saved and rerender form' do
    log_in_as(@admin)

    # For Create
    assert_no_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: { slug: ' ',
                                                   redirect: 'www.google,com' } }
    end
    assert_template 'short_urls/new'

    # For Update
    original_alias    = @short_url.slug
    original_redirect = @short_url.redirect
    patch short_url_path(@short_url), params: { short_url: { slug: '',
                                                             redirect: 'http://www.google,com' } }
    assert @short_url.slug == original_alias
    assert @short_url.redirect  == original_redirect
    assert_template 'short_urls/edit'
  end

  test 'admins can get edit' do
    log_in_as(@admin)
    get edit_short_url_path(@short_url)
    assert_response :success
  end

  test 'normal users cannot get edit' do
    log_in_as(@user)
    get edit_short_url_path(@short_url)
    assert_redirected_to root_url
  end

  test 'admins can patch update' do
    log_in_as(@admin)
    new_alias    = 'zomg'
    new_redirect = 'flyinggrizzly.io'
    patch short_url_path(@short_url), params: { short_url: { slug: new_alias,
                                                             redirect:  new_redirect } }
    assert_equal new_alias,     @short_url.reload.slug
    assert_equal new_redirect,  @short_url.reload.redirect
  end

  test 'normal users cannot patch update' do
    log_in_as(@user)
    new_alias    = 'zomg'
    new_redirect = 'http://flyinggrizzly.io'
    patch short_url_path(@short_url), params: { short_url: { slug: new_alias,
                                                             redirect:  new_redirect } }
    assert_not_equal new_alias,    @short_url.reload.slug
    assert_not_equal new_redirect, @short_url.reload.redirect
  end

  test 'admins can get delete' do
    log_in_as(@admin)
    get delete_short_url_path(@short_url)
    assert_response :success
  end

  test 'normal users cannot get delete' do
    log_in_as(@user)
    get delete_short_url_path(@short_url)
    assert_redirected_to root_url
  end

  test 'admins can destroy' do
    log_in_as(@admin)
    assert_difference 'ShortUrl.count', -1 do
      delete short_url_path(@short_url)
    end
  end

  test 'normal users cannot destroy' do
    log_in_as(@user)
    assert_no_difference 'ShortUrl.count' do
      delete short_url_path(@short_url)
    end
    assert_redirected_to root_url
  end
end
