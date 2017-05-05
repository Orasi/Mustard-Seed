FactoryGirl.define do
  factory :keyword do

    keyword {Faker::Crypto.unique.md5}

  end
end