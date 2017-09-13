FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@url.grey" }
    password         'tea-earl-grey-hot'
    admin            false
  end

  factory :admin_user, class: User do
    sequence(:name)  { |n| "Admin User #{n}" }
    sequence(:email) { |n| "admin-#{n}@url.grey" }
    password         'tea-earl-grey-hot'
    admin            true
  end
end
