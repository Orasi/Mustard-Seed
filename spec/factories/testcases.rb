FactoryGirl.define do
  factory :testcase do

    name {Faker::Lorem.unique.sentence}
    validation_id {rand 1000000..9999999}
    reproduction_steps {[{step_number: 1, action: Faker::Lorem.sentence, result: Faker::Lorem.sentence},
                         {step_number: 2, action: Faker::Lorem.sentence, result: Faker::Lorem.sentence},
                         {step_number: 3, action: Faker::Lorem.sentence, result: Faker::Lorem.sentence}]}

  end
end