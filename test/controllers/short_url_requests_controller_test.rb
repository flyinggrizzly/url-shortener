require 'test_helper'

class ShortUrlRequestsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @real_short_url = short_urls(:example)
    @fake_short_url = ShortUrl.new(slug: 'nonono', redirect: 'http://rubyonrails.org') # Don't save
  end

  test 'requesting an existing short url redirects' do
    get "/#{@real_short_url.slug}"
    assert_redirected_to @real_short_url.redirect
  end

  test 'requesting a bad short url redirects home' do
    get "/#{@fake_short_url.slug}"
    assert_redirected_to root_url
    assert_not flash.empty?
  end
end
