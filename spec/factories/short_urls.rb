FactoryGirl.define do
  factory :short_url do
    sequence(:slug) { |n| "#{n}" }
    redirect 'https://www.flyinggrizzly.io'
  end

  factory :short_url_with_slug_like_slug, class: ShortUrl do
    sequence(:slug) { |n| "slug-#{n}" }
    redirect 'https://www.flyinggrizzly.io'
  end

  factory :short_url_with_slug_like_foo, class: ShortUrl do
    sequence(:slug) { |n| "foo-#{n}" }
    redirect 'https://www.flyinggrizzly.io'
  end
end
