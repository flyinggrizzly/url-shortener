require 'test_helper'

class ShortUrlsCreationTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    log_in_as(@admin)
    @good_params = { slug: 'foobar',
                     redirect:  'http://whitehouse.gov' }
    @bad_params  = { slug: '',
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

  test 'form has right fields' do
    get new_short_url_path
    assert_select 'input[name=?]', 'short_url[slug]'
    assert_select 'input[name=?]', 'short_url[redirect]'
    assert_select 'input[name=?]', 'short_url[random_slug]'
  end

  test 'random slugs are generated when requested' do
    assert_difference 'ShortUrl.count', 1 do
      post short_urls_path, params: { short_url: { slug:        '',
                                                   random_slug: '1',
                                                   redirect:    'https://www.google.com' } }
    end
  end

  test 'random slugs do not overwrite custom slugs' do
    slug = 'do-not-overwrite'
    short_url = ShortUrl.new(slug:        slug,
                             random_slug: '1',
                             redirect:    'https://www.google.com')
    short_url.save
    assert_equal slug, short_url.reload.slug
  end
end
