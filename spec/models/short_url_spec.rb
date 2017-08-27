require 'rails_helper'

RSpec.describe ShortUrl, type: :model do

  def short_url_params(slug: 'slug', redirect: 'https://www.flyinggrizzly.io')
    { slug: slug, redirect: redirect }
  end

  it 'has a valid factory' do
    expect(FactoryGirl.build(:short_url)).to be_valid
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
        short_url = ShortUrl.new(short_url_params(slug: slug))
        expect(short_url).not_to be_valid
      end

      slug_with_all_allowed_chars = '1234567890-abcdefghijklmnopqrstuvwxyz'
      short_url = ShortUrl.new(short_url_params(slug: slug_with_all_allowed_chars))
      expect(short_url).to be_valid
    end

    it 'cannot be a reserved slug', :aggregate_failures do
      UrlGrey::Application.config.reserved_slugs.each do |slug|
        short_url = ShortUrl.new(short_url_params(slug: slug))
        expect(short_url).not_to be_valid
      end
    end

    it 'should be 255 characters or less', :aggregate_failures do
      slug = 'a' * 255
      short_url = ShortUrl.new(short_url_params(slug: slug))
      expect(short_url).to be_valid

      slug << 'a'
      short_url = ShortUrl.new(short_url_params(slug: slug))
      expect(short_url).not_to be_valid
    end
  end

  describe 'redirect' do
    it 'should be a valid URL', :aggregate_failures do
      pending "need to fix URL validation"
      short_url = ShortUrl.new(short_url_params(redirect: 'foo'))
      expect(short_url).not_to be_valid

      short_url = ShortUrl.new(short_url_params(slug: 'bar', redirect: 'https://www,flyinggrizzly.io'))
      expect(short_url).not_to be_valid
    end

    it 'should have a scheme when saved' do
      short_url = ShortUrl.create(short_url_params(redirect: 'www.flyinggrizzly.io'))
      expect(short_url.reload.redirect).to eq('http://www.flyinggrizzly.io')
    end

    it 'cannot redirect to the app host' do
      # Put application host into a temporary var for safekeeping
      app_host = UrlGrey::Application.config.application_host

      UrlGrey::Application.config.application_host = 'https://grz.li'
      short_url = ShortUrl.new(short_url_params(redirect: 'https://grz.li/foo'))
      expect(short_url).not_to be_valid

      # Restore the application host value
      UrlGrey::Application.config.application_host = app_host
    end
  end

  describe 'papertrail', versioning: true do
    it 'should record old redirect targets', aggregate_failures: true do
      short_url = ShortUrl.create(slug: 'slug', redirect: 'https://site-0.com')
      3.times do |n|
        short_url.redirect = "https://site-#{n + 1}.com"
        short_url.save
        # expectation is always 1 version behind the updates
        expect(short_url).to have_a_version_with redirect: "https://site-#{n}.com"
      end
    end

    it 'should record who made changes' do
      pending "this should be tested at acceptance/system level"
      short_url = FactoryGirl.create(:short_url)
      short_url.redirect = 'https://www.foobar.com'
      short_url.save
      expect(short_url.versions.last.whodunnit).not_to be_blank
    end
  end

  describe '::search(query)', :aggregate_failures do
    it 'should return short URLs that match the substring query' do
      2.times do
        FactoryGirl.create(:short_url_with_slug_like_slug)
        FactoryGirl.create(:short_url_with_slug_like_foo)
      end
      expect(ShortUrl.search('foo').count).to  eq(2)
      expect(ShortUrl.search('slug').count).to eq(2)

      # search is currently just a Postgres ILIKE lookup,
      # substrings should also work
      expect(ShortUrl.search('lug').count).to eq(2)
      expect(ShortUrl.search('fo').count).to eq(2)
    end

    it "should not return short URLs that don't match the substring query" do
      2.times do
        FactoryGirl.create(:short_url_with_slug_like_slug)
      end
      ShortUrl.search('slug').each do |result|
        expect(result.slug).not_to eq('gopher')
      end
    end
  end

  describe '::reverse_search(query)' do
    it 'should return short URLs that match the query' do
      FactoryGirl.create(:short_url, redirect: 'https://www.flyinggrizzly.io/awesome/')
      FactoryGirl.create(:short_url, redirect: 'https://www.flyinggrizzly.io/awesome/page/')
      FactoryGirl.create(:short_url, redirect: 'https://www.flyinggrizzly.io/awesome/cv/')
      FactoryGirl.create(:short_url, redirect: 'https://www.flyinggrizzly.io/awesome/project/')
      expect(ShortUrl.reverse_search('flyinggrizzly.io/awesome').count).to eq(4)
    end

    it "should not return short URLs that don't match the query" do
      3.times do |n|
        FactoryGirl.create(:short_url, redirect: "https://www.flyinggrizzly.io/#{n}/")
      end
      expect(ShortUrl.reverse_search('thatsite.com').count).to eq(0)
    end
  end

  describe '::random_slug' do
    it 'should return a 4 character slug' do
      expect(ShortUrl.random_slug.size).to eq(4)
    end

    it 'should not return a slug that is already in use' do
      ShortUrl.create(slug: ShortUrl.random_slug, redirect: 'https://www.flyinggrizzly.io')
      short_url = ShortUrl.new(slug: ShortUrl.random_slug, redirect: 'https://www.flyinggrizzly.io')
      expect(short_url).to be_valid
    end

    it 'should set up the counter if not already set' do
      # ensure the current_random_slug config value is set for sure (might be already, might not)
      ShortUrl.random_slug
      # destroy it
      AppConfig.destroy :current_random_slug

      # try to use it when it does not exist
      ShortUrl.random_slug
      # test that it's been created
      expect(AppConfig.current_random_slug).to eq(1)
    end

    it "should not return slugs that include '-'" do
      AppConfig.current_random_slug = 20571 # will return 'f0-' with the base 37 conversion
      expect(ShortUrl.random_slug).not_to include('-')
    end

    it 'should increment the base 37 counter after creating a slug' do
      expect { ShortUrl.random_slug }.to change { AppConfig.current_random_slug }.by_at_least(1)
    end
  end

  describe '::base_37_convert(number)' do
    it "should convert 0 through 36 to 0 through '-'", :aggregate_failures do
      %w(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z -).each_with_index do |char, n|
        expect(ShortUrl.base_37_convert(n)).to eq(char)
      end
    end

    it 'should convert 37 to 10' do
      expect(ShortUrl.base_37_convert(37)).to eq("10")
    end
  end
end
