require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  def setup
    @user = users(:cthulhu)
    @short_url = ShortUrl.new(url_alias: 'foobar',
                                         redirect:  'http://www.google.com')
  end

  test 'should be valid' do
    assert @short_url.valid?
  end

  test 'alias is downcased when saving' do
    mixed_case_alias = 'AdfDGG87uF'
    @short_url.url_alias = mixed_case_alias
    @short_url.save
    assert_equal mixed_case_alias.downcase, @short_url.reload.url_alias
  end

  test 'must have alias' do
    @short_url.url_alias = nil
    assert_not @short_url.valid?
  end

  test 'must have redirect' do
    @short_url.redirect = nil
    assert_not @short_url.valid?
  end
end
