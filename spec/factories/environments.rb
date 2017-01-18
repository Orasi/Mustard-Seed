FactoryGirl.define do
  factory :environment do

    uuid {Faker::Crypto.md5}

  end
end