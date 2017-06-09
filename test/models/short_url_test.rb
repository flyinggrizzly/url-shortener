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

  test 'should have http scheme prepended before save if no scheme' do
    redirect = 'www.google.com'
    @short_url.redirect = redirect
    @short_url.save
    assert_equal 'http://' + redirect, @short_url.reload.redirect
  end

  test 'scheme should not be changed when scheme exists' do
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

  test 'slugs cannot equal login or logout' do
    @short_url.slug = 'login'
    assert_not @short_url.valid?

    @short_url.slug = 'logout'
    assert_not @short_url.valid?
  end

  test 'search works' do
    @short_url.save
    assert_includes ShortUrl.search(@short_url.slug), @short_url
  end

  test 'search works for values with multiple hits' do
    20.times do |n|
      slug = "slug_#{n}"
      redirect = 'http://www.google.com'
      ShortUrl.create!(slug: slug, redirect: redirect)
    end
    short_url = ShortUrl.new(slug: 'slug_20', redirect: 'http://www.google.com')
    short_url.save

    assert_includes ShortUrl.search('slug_'), short_url
    assert_equal 21, ShortUrl.search('slug_').size
  end

  test 'reverse search works' do
    @short_url.save
    assert_includes ShortUrl.reverse_search(@short_url.redirect), @short_url
  end

  test 'reverse search works for values with multiple hits' do
    20.times do |n|
      slug = "slug_#{n}"
      redirect = "http://www.numbered-domain-#{n}.com"
      ShortUrl.create!(slug: slug, redirect: redirect)
    end
    short_url = ShortUrl.new(slug: 'slug_20', redirect: 'http://www.numbered-domain-20.com')
    short_url.save

    assert_includes ShortUrl.reverse_search('www.numbered-domain-'), short_url
    assert_equal 21, ShortUrl.reverse_search('www.numbered-domain-').size
  end

  test 'random slugs are unique' do
    # Make sure the test database starts iterating over random slugs from the beginning
    AppConfig.current_random_slug = 0

    # Create 1 char short URLs for all options except 'z'
    ('a'..'y').each do |c|
      ShortUrl.create!(slug: c, redirect: 'https://www.google.com')
    end
    ('0'..'9').each do |c|
      ShortUrl.create!(slug: c, redirect: 'https://www.google.com')
    end

    # 'z' is the only possible unique slug of length 1
    assert_equal 'z', ShortUrl.random_slug(1)
  end

  test 'random slugs are the right length' do
    assert_equal UrlGrey::Application.config.random_slug_length, ShortUrl.random_slug.length
    assert_equal 2, ShortUrl.random_slug(2).length
  end

  test 'custom random-slug length is increased if no more options at custom length' do
    # Make sure we start random slug count from 0
    AppConfig.current_random_slug = 0

    # Park all single char slugs
    ('a'..'z').each do |c|
      ShortUrl.create!(slug: c, redirect: 'https://www.google.com')
    end
    ('0'..'9').each do |c|
      ShortUrl.create!(slug: c, redirect: 'https://www.google.com')
    end

    assert_equal 2, ShortUrl.random_slug(1).length
  end

  test 'random slugs do not contain hyphens' do
    # Make sure we start slugs from 0
    AppConfig.current_random_slug = 0
    # For every possible configuration of a random slug with length 2 chars
    (37**2).times do |n|
      assert_not ShortUrl.random_slug(2).include?('-')
    end
  end
end
