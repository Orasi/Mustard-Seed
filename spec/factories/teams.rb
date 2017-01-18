FactoryGirl.define do
  factory :team do

    name {Faker::Company.unique.name}
    description {Faker::Hacker.say_something_smart}

    transient do
      users_count 2
      projects_count 2
    end

    after(:create) do |team, evaluator|
      evaluator.users_count.times do

      end
      create_list(:user, evaluator.users_count, teams: [team])
      create_list(:project, evaluator.projects_count, teams: [team])
    end
  end
end