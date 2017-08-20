require 'test_helper'

class ShortUrlsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    @user  = users(:yig)
    @short_url = short_urls(:google)
  end

  test 'admins can get index' do
    log_in_as(@admin)
    get short_urls_path
    assert_response :success
  end

  test 'normal users can get index' do
    log_in_as(@user)
    get short_urls_path
    assert_response :success
  end

  test 'admins can get show' do
    log_in_as(@admin)
    get short_url_path(@short_url)
    assert_response :success
  end

  test 'normal users can get show' do
    log_in_as(@user)
    get short_url_path(@short_url)
    assert_response :success
  end

  test 'admins can get new' do
    log_in_as(@admin)
    get new_short_url_path
    assert_response :success
  end

  test 'normal users can get new' do
    log_in_as(@user)
    get new_short_url_path
    assert_response :success
  end

  test 'admins can create short urls' do
    log_in_as(@admin)
    assert_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: { slug: 'foo',
                                                 redirect: 'http://www.google.com' } }
    end
  end

  test 'normal users can create short urls' do
    log_in_as(@user)
    assert_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: { slug: 'foo',
                                                   redirect:  'http://www.google.com' } }
    end
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
    original_redirect = @short_url.redirect
    patch short_url_path(@short_url), params: { short_url: { redirect: '  ' } }
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
    assert_redirected_to root_or_admin_url
  end

  test 'admins can patch update' do
    log_in_as(@admin)
    new_redirect = 'http://flyinggrizzly.io'
    patch short_url_path(@short_url), params: { short_url: { redirect: new_redirect } }
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

  test 'cannot change slug when editing' do
    log_in_as(@admin)
    old_slug = @short_url.slug
    new_slug = 'zomg'
    patch short_url_path(@short_url), params: { short_url: { slug: new_slug } }
    assert_equal old_slug, @short_url.reload.slug
  end

  test 'admins can get delete' do
    log_in_as(@admin)
    get delete_short_url_path(@short_url)
    assert_response :success
  end

  test 'normal users cannot get delete' do
    log_in_as(@user)
    get delete_short_url_path(@short_url)
    assert_redirected_to root_or_admin_url
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
    assert_redirected_to root_or_admin_url
  end

  test 'admins can search' do
    log_in_as(@admin)
    get search_short_urls_path
    assert_response :success
  end

  test 'normal users can search' do
    log_in_as(@user)
    get search_short_urls_path
    assert_response :success
  end

  test 'unauthenticated users can search' do
    get search_short_urls_path
    assert_response :success
  end

  test 'short url resource paths displays as short-url' do
    log_in_as(@admin)

    # Index
    assert_includes     short_urls_path, 'short-url'
    assert_not_includes short_urls_path, 'short_url'

    # Show
    assert_includes     short_url_path(@short_url), 'short-url'
    assert_not_includes short_url_path(@short_url), 'short_url'

    # Edit
    assert_includes     edit_short_url_path(@short_url), 'short-url'
    assert_not_includes edit_short_url_path(@short_url), 'short_url'

    # Delete
    assert_includes     delete_short_url_path(@short_url), 'short-url'
    assert_not_includes delete_short_url_path(@short_url), 'short_url'
  end

  test 'short URL slugs not IDs appear in path' do
    log_in_as(@admin)

    # Show
    assert_includes     short_url_path(@short_url), @short_url.slug
    assert_not_includes short_url_path(@short_url), @short_url.id.to_s

    # Edit
    assert_includes     edit_short_url_path(@short_url), @short_url.slug
    assert_not_includes edit_short_url_path(@short_url), @short_url.id.to_s

    # Delete
    assert_includes     delete_short_url_path(@short_url), @short_url.slug
    assert_not_includes delete_short_url_path(@short_url), @short_url.id.to_s
  end

  test 'create has papertrail' do
    with_versioning do
      log_in_as(@user)
      post short_urls_path, params: { short_url: { slug:      'versioned_create',
                                                   redirect:  'http://www.google.com' } }
      short_url = ShortUrl.find_by(slug: 'versioned_create')
      assert short_url.versions
      assert_equal @user.id.to_s, short_url.versions.last.whodunnit
    end
  end

  test 'update has papertrail' do
    with_versioning do
      log_in_as(@admin)
      old_url = @short_url
      patch short_url_path(@short_url), params: { short_url: { redirect: 'https://github.com/airblade/paper_trail' } }
      assert @short_url.versions
      assert_equal old_url, @short_url.versions.last.reify
      assert_equal @admin.id.to_s, @short_url.versions.last.whodunnit
    end
  end

  test 'destroy has papertrail' do
    with_versioning do
      log_in_as(@admin)
      short_url = ShortUrl.new(slug: 'versioned_destroy', redirect: 'https://github.com/airblade/paper_trail')
      short_url.save

      old_url = short_url
      delete short_url_path(short_url)

      assert_equal "destroy", short_url.versions.last.event
      assert_equal old_url, short_url.versions.last.reify
      assert_equal @admin.id.to_s, short_url.versions.last.whodunnit
    end
  end

  test 'admin can access create many screen' do
    log_in_as(@admin)
    get many_new_short_urls_path
    assert_response :success
    # assert_select 'input[type=button]#upload_csv'
    log_out
  end

  test 'non admin cannot access create many screen' do
    # accessing fixture directly rather than from set up because
    # the @user var from setup keeps throwing errors when
    # used here
    log_in_as(@user)
    get many_new_short_urls_path
    assert_response :redirect
    log_out
  end

  test 'logged out users cannot access create many screen' do
    get many_new_short_urls_path
    assert_response :redirect
  end
end
