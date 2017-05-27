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

  test 'must have slug' do
    @short_url.slug = nil
    assert_not @short_url.valid?
  end

  test 'slugs must be unique' do
    @short_url.save
    new_short = ShortUrl.new(slug: 'foobar',
                             redirect: 'https://www.example.com')
    assert_no_difference 'ShortUrl.count' do
      new_short.save
    end
  end

  test 'must have redirect' do
    @short_url.redirect = nil
    assert_not @short_url.valid?
  end

  test 'slugs should be of an acceptable format' do
    # Does not begin with hyphen
    @short_url.slug = '-abc123'
    assert_not @short_url.valid?

    # Does not begin with underscore
    @short_url.slug = '_abc123'
    assert_not @short_url.valid?

    # Does not end with hyphen
    @short_url.slug = 'abc123-'
    assert_not @short_url.valid?

    # Does not end with underscore
    @short_url.slug = 'abc123_'
    assert_not @short_url.valid?

    # Does not contain slash (important enough to get its own assertion)
    @short_url.slug = 'abc/123'
    assert_not @short_url.valid?

    # Contains a hyphen
    @short_url.slug = 'abc-123'
    assert @short_url.valid?

    # Contains an underscore
    @short_url.slug = '123_abc'
    assert @short_url.valid?

    # Cannot contain asterisks
    @short_url.slug = '*123'
    assert_not @short_url.valid?
    @short_url.slug = '123*'
    assert_not @short_url.valid?
    @short_url.slug = '12*3'
    assert_not @short_url.valid?

    # Cannot contain periods
    @short_url.slug = '12.3'
    assert_not @short_url.valid?

    # Semicolon
    @short_url.slug = 'abc;123'
    assert_not @short_url.valid?
  end

  test 'slugs cannot equal admin' do
    @short_url.slug = 'admin'
    assert_not @short_url.valid?
  end
end
