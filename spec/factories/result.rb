FactoryGirl.define do
  factory :result do

    environment_id -1
    testcase_id -1
    execution_id -1
    results {[]}
    current_status {['fail', 'fail', 'skip'].sample}

    trait :manual do
      environment_id -1
    end

    trait :pass do
      status 'pass'
    end

    trait :skip do
      status 'skip'
    end

    trait :fail do
      status 'fail'
    end

    transient do
      user {FactoryGirl.create(:user)}
      results_count 3
    end


    after(:build) do |result, evaluator|

      if result.environment_id == -1
        evaluator.results_count.times do
          result.results.prepend({status: ['pass', 'fail', 'skip'].sample,
                                  result_type: 'manual',
                                  comment: Faker::Lorem.sentence,
                                  created_at: DateTime.now,
                                  created_by_id: evaluator.user.id,
                                  created_by_name: "#{evaluator.user.first_name} #{evaluator.user.last_name}".titleize
                                 })
        end
      else
        evaluator.results_count.times do
          result.results.prepend({status: ['pass', 'fail', 'skip'].sample,
                                  result_type: 'automated',
                                  stacktrace: Faker::Lorem.paragraph,
                                  comment: Faker::Lorem.sentence,
                                  link: Faker::Internet.url,
                                  created_at: DateTime.now,
                                 })
        end

      end

      result.current_status = result.results.first[:status]

    end
  end
end

