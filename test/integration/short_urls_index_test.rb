require 'test_helper'

class ShortUrlsIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    log_in_as(@admin)
    @short_url = short_urls(:example)
  end

  test 'index shows right short urls' do
    get short_urls_path
    assert_select 'div.pagination', count: 2
    ShortUrl.paginate(page: 1).each do |short_url|
      assert_select 'a[href=?]', short_url_path(short_url),        text: short_url.url_alias
      assert_select 'a[href=?]', edit_short_url_path(short_url),   text: 'Edit'
      assert_select 'a[href=?]', delete_short_url_path(short_url), text: 'Delete'
    end
  end
end
