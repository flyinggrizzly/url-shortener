require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  def setup
    @user = users(:cthulhu)
    @short_url = @user.short_urls.build(url_alias: 'foobar',
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

  test 'redirects without schema have http prepended' do
    @short_url.redirect = 'www.example.com'
    assert @short_url.valid?
    assert_equal 'http://www.example.com', @short_url.redirect
  end

  test 'redirects with schema do not have one prepended' do
    broken_schemes = %w(http://http:// https://http:// http://https:// https://https://)
    
    # Redirects beginning with http://
    @short_url.redirect = 'http://www.google.com'
    @short_url.save
    broken_schemes.each do |scheme|
      assert_not @short_url.reload.redirect.start_with?(scheme)
    end

    # Redirects beginning with https://
    @short_url.redirect = 'https://www.google.com'
    @short_url.save
    broken_schemes.each do |scheme|
      assert_not @short_url.reload.redirect.start_with?(scheme)
    end
  end

  test 'must have alias' do
    @short_url.url_alias = nil
    assert_not @short_url.valid?
  end

  test 'must have redirect' do
    @short_url.redirect = nil
    assert_not @short_url.valid?
  end

  test 'user_id should be present' do
    @short_url.user_id = nil
    assert_not @short_url.valid?
  end
end
