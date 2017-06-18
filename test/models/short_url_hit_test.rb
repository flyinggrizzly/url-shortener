require 'test_helper'

class ShortUrlHitTest < ActiveSupport::TestCase
  test 'must have short_url_id' do
    short_url_hit = ShortUrlHit.new(short_url_id: '',
                                    ip_address:   '0.0.0.0',
                                    user_agent:   'chrome')
    assert_not short_url_hit.valid?

    short_url_hit = short_urls(:example).hits.build(ip_address: '0.0.0.0',
                                                    user_agent: 'chrome')
    short_url_hit.save
    short_url_hit.reload
    assert_equal short_urls(:example).id, short_url_hit.short_url_id
  end

  test 'no hit logged if short_url_id is not present' do
    short_url_hit = ShortUrlHit.new(short_url_id: '',
                                    ip_address:   '0.0.0.0',
                                    user_agent:   'chrome')
    assert_no_difference 'ShortUrlHit.count' do
      short_url_hit.save
    end
  end
end
