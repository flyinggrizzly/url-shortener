require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  def setup
    @user = users(:cthulhu)
    @short_url = ShortUrl.new(slug: 'foobar',
                                         redirect:  'http://www.google.com')
  end

  test 'should be valid' do
    assert @short_url.valid?
  end

  test 'should have http scheme prepended before save' do
    redirect = 'www.google.com'
    @short_url.redirect = redirect
    @short_url.save
    assert_equal 'http://' + redirect, @short_url.reload.redirect
  end

  test 'should not have http prepended when scheme exists' do
    redirect = 'http://www.google.com'
    @short_url.redirect = redirect
    @short_url.save
    assert_equal redirect, @short_url.reload.redirect

    redirect = 'https://www.google.com'
    @short_url.redirect = redirect
    @short_url.save
    assert_equal redirect, @short_url.reload.redirect
  end

  test 'alias is downcased when saving' do
    mixed_case_alias = 'AdfDGG87uF'
    @short_url.slug = mixed_case_alias
    @short_url.save
    assert_equal mixed_case_alias.downcase, @short_url.reload.slug
  end

  test 'must have alias' do
    @short_url.slug = nil
    assert_not @short_url.valid?
  end

  test 'must have redirect' do
    @short_url.redirect = nil
    assert_not @short_url.valid?
  end
end
