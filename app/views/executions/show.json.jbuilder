json.execution do
  json.id @execution.id
  json.name @execution.name
  json.project_id @execution.project_id
  json.fast true if @execution.fast
  json.closed @execution.closed
  json.closed_at @execution.closed_at if @execution.closed
  json.created_at @execution.created_at
  json.updated_at @execution.updated_at
  json.testcases @execution.execution_testcases.order(:validation_id, :id) do |tc|
    json.id tc.id
    json.testcase_name tc.name
    json.testcase_id tc.validation_id if tc.validation_id
    # json.created_at tc.created_at
    json.updated_at tc.updated_at
    json.version tc.version if tc.version
  end
  json.environments @execution.execution_environments do |env|
    json.id env.id
    json.uuid env.uuid
    json.display_name env.display_name
    json.environment_type env.environment_type
    json.created_at env.created_at
    json.updated_at env.updated_at
  end
  json.keywords @execution.execution_keywords do |keyword|
    json.id keyword.id
    json.keyword keyword.keyword
    json.testcase_count keyword.testcase_count
  end
end