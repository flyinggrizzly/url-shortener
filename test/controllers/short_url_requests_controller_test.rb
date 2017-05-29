require 'test_helper'

class ShortUrlRequestsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @real_short_url = short_urls(:google)
    @fake_short_url = ShortUrl.new(slug: 'nonono', redirect: 'http://rubyonrails.org/') # Don't save
  end

  test 'requesting an existing short url redirects' do
    get "/#{@real_short_url.slug}"
    assert_redirected_to @real_short_url.redirect
  end

  test 'requesting a bad short url redirects home' do
    get "/#{@fake_short_url.slug}"
    assert_redirected_to root_or_admin_url
    assert_not flash.empty?
  end

  test 'requesting a good short url with different case works' do
    get "/#{@real_short_url.slug.upcase}"
    assert_redirected_to @real_short_url.redirect

    get "/#{@real_short_url.slug.capitalize}"
    assert_redirected_to @real_short_url.redirect

    camel_case_slug = String.new
    @real_short_url.slug.split('').each_with_index do |char, index|
      char = char.upcase if (index + 1) % 2 == 0
      camel_case_slug[index] = char
    end
    get "/#{camel_case_slug}"
    assert_redirected_to @real_short_url.redirect
  end
end
