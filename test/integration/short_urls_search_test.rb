require 'test_helper'

class ShortUrlsSearchTest < ActionDispatch::IntegrationTest
  def setup
    20.times do |n|
      ShortUrl.create!(slug: "slug_#{n}", redirect: "http://www.numbered-domain-#{n}.com")
    end
  end

  test 'search shows results' do
    get search_short_urls_path, params: { search: 'slug_' }
    assert_select 'li.short_url', count: 20
  end

  test 'reverse search shows results' do
    get search_short_urls_path, params: { reverse_search: 'www.numbered-domain-' }
    assert_select 'li.short_url', count: 20
  end
end
