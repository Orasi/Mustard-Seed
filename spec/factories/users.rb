FactoryGirl.define do
  factory :user do


    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    password '12345'
    password_confirmation '12345'
    company {Faker::Company.name}
    username  {Faker::Internet.user_name}
    email {Faker::Internet.email}

    trait :admin do
      admin true
    end

    after(:create) do |u|
      create :user_token, user_id: u.id
    end
  end

  factory :user_token do
    expires {Time.now + 2.hours}
  end
end