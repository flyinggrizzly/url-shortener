require 'test_helper'

class ShortUrlsShowTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    @short_url = short_urls(:hits_test)
    log_in_as(@admin)
  end

  test 'shows slug as heading' do
    get short_url_path(@short_url)
    assert_select 'h2', @short_url.slug
  end

  test 'shows edit and delete buttons' do
    get short_url_path(@short_url)
    assert_select 'a[href=?]', edit_short_url_path(@short_url)
    assert_select 'a[href=?]', delete_short_url_path(@short_url)
  end

  test 'shows stats' do
    get short_url_path(@short_url)
    assert_select 'div.short-url-stats', 1
    assert_select 'div.short-url-stat', 2
    assert_select 'span.stat-gloss', 2
    assert_select 'span.stat-entry', 2
  end
end
