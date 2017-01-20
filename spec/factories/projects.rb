FactoryGirl.define do
  factory :project do

    name {Faker::Company.unique.name}

    transient do
      environments_count 5
      testcases_count 5
      results_range 0..0
    end

    after(:create) do |project, evaluator|
      create_list(:environment, evaluator.environments_count, project: project)
      create_list(:testcase, evaluator.testcases_count, project: project)

      evaluator.testcases.each do |t|
        results_count = rand(evaluator.results_range)
        evaluator.environments.each do |e|
            unless results_count == 0
              create(:result, execution: project.executions.open_execution, testcase: t, environment: e, results_count: results_count)
            end

        end

        create(:result, execution: project.executions.open_execution, testcase: t, environment_id: -1) unless results_count == 0
      end

    end
  end
end