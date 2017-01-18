FactoryGirl.define do
  factory :project do

    name {Faker::Company.unique.name}

    transient do
      environments_count 5
      testcases_count 5
    end

    after(:create) do |project, evaluator|
      create_list(:environment, evaluator.environments_count, project: project)
      create_list(:testcase, evaluator.testcases_count, project: project)
    end
  end
end