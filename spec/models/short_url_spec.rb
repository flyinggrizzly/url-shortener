require 'rails_helper'

RSpec.describe ShortUrl, type: :model do

  def short_url_params(slug: 'slug', redirect: 'https://www.flyinggrizzly.io')
    { slug: slug, redirect: redirect }
  end

  it 'is valid with a slug and a redirect' do
    short_url = ShortUrl.new(short_url_params)
    expect(short_url).to be_valid
  end

  it 'is invalid without a slug' do
    short_url = ShortUrl.new(short_url_params(slug: ''))
    expect(short_url).not_to be_valid
  end

  it 'is invalid without a redirect' do 
    short_url = ShortUrl.new(short_url_params(redirect: ''))
    expect(short_url).not_to be_valid
  end

  it 'is invalid with a duplicate slug' do
    ShortUrl.create(short_url_params)
    short_url = ShortUrl.new(short_url_params)
    expect(short_url).not_to be_valid
  end

  it 'has a papertrail', versioning: true, aggregate_failures: true do
    short_url = ShortUrl.create(short_url_params)
    short_url.update_attribute(:redirect, 'http://flyinggrizzly.io')
    short_url.update_attribute(:redirect, 'https://www.google.com')
    expect(short_url.versions.length).to eq(3)
  end

  it 'has many hits', :aggregate_failures do
    short_url = ShortUrl.create(short_url_params)
    expect(short_url).to respond_to(:hits)
    expect(short_url.hits.count).to eq(0)

    short_url.hits.build.save
    expect(short_url.hits.count).to eq(1)
  end

  it 'should use its slug as the param' do
    short_url = ShortUrl.create(short_url_params)
    expect(short_url.to_param).to eq(short_url.slug)
  end

  describe 'slug' do
    it "is only valid with a-z, 0-9, and '-'", :aggregate_failures do
      common_bad_single_char_slugs = %w(! @ # $ % £ ^ & * _ + = [ ] \ | / ? . > , < ` ~  ; : { } )
      common_bad_single_char_slugs.each do |slug|
        short_url = ShortUrl.create(short_url_params(slug: slug))
        expect(short_url).not_to be_valid
      end

      slug_with_all_allowed_chars = '1234567890-abcdefghijklmnopqrstuvwxyz'
      short_url = ShortUrl.create(short_url_params(slug: slug_with_all_allowed_chars))
      expect(short_url).to be_valid
    end

    it 'cannot be a reserved slug', :aggregate_failures do
      UrlGrey::Application.config.reserved_slugs.each do |slug|
        short_url = ShortUrl.create(short_url_params(slug: slug))
        expect(short_url).not_to be_valid
      end
    end

    it 'should be 255 characters or less' do
      slug = 'a' * 256
      short_url = ShortUrl.create(short_url_params(slug: slug))
      expect(short_url).not_to be_valid
    end
  end

  describe 'redirect' do
    it 'should be a valid URL'
    it 'should have a scheme when saved'
    it 'cannot redirect to the app host'
  end

  describe 'papertrail' do
    it 'should record old redirect targets'
    it 'should record deletions'
    it 'should record who made changes'
  end

  describe 'hits' do
    it 'should have hits'
  end

  describe '::search(query)' do
    it 'should return short URLs that match the query'
    it "should not return short URLs that don't match the query"
  end

  describe '::reverse_search(query)' do
    it 'should return short URLs that match the query'
    it "should not return short URLs that don't match the query"
  end

  describe '::random_slug' do
    it 'should return a random 4 chracter slug'
    it 'should not return a slug that is already in use'
    it 'should not return a slug that is reserved'
    it "should not return slugs that include '-'"
    it 'should increment the base 37 counter after creating a slug'
  end

  describe '::base_37_convert(number)' do
    it "should convert 0 through 36 to 0 through '-'"
    it 'should convert 37 to 10'
  end
end
