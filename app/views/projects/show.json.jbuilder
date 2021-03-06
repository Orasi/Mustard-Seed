json.project do
  json.id @project.id
  json.project_name @project.name
  json.api_key @project.api_key
  json.created_at @project.created_at
  json.updated_at @project.updated_at
  if @testcases
    json.testcases @testcases.order(:validation_id, :id) do |tc|
      json.id tc.id
      json.testcase_name tc.name
      json.testcase_id tc.validation_id if tc.validation_id
      # json.created_at tc.created_at
      json.updated_at tc.updated_at
      json.version tc.version if tc.version
      json.keywords tc.keywords if tc.keywords
    end
  else
    json.testcases []
  end
  json.environments @project.environments do |env|
    json.id env.id
    json.uuid env.uuid
    json.display_name env.display_name
    json.environment_type env.environment_type
    json.created_at env.created_at
    json.updated_at env.updated_at
  end
  json.executions @project.executions.order(:created_at).reverse do |exc|
    json.id exc.id
    json.name exc.name
    json.fast true if exc.fast
    json.closed exc.closed
    json.created_at exc.created_at
    json.updated_at exc.updated_at
  end
  json.keywords @project.keywords do |keyword|
    json.id keyword.id
    json.keyword keyword.keyword
    json.testcase_count keyword.testcase_count
  end
end