require 'test_helper'

class ShortUrlsCreationTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    log_in_as(@admin)
    @good_params = { url_alias: 'foobar',
                     redirect:  'http://whitehouse.gov' }
    @bad_params  = { url_alias: '',
                     redirect:  'htfp://whitehouse,gov' }
  end

  test 'invalid params should not be accepted' do
    get new_short_url_path
    assert_no_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: @bad_params }
    end
    assert_template 'short_urls/new'
    assert_select 'div#error_explanation'
    assert_select 'li.error-item', count: 2
  end

  test 'valid params should be accepted' do
    get new_short_url_path
    assert_difference 'ShortUrl.count' do
      post short_urls_path, params: { short_url: @good_params }
    end
    assert_redirected_to short_urls_path
    assert_not flash.empty?
  end
end
