FactoryGirl.define do
  factory :short_url_hit do
    sequence(:ip_address) { |n| "0.0.0.#{n}" }
    user_agent "Chrome/Webkit"
    association :short_url
  end
end