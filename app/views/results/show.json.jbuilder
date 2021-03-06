json.result do
  json.id @result.id
  json.environment_id @result.environment_id
  json.environment_display_name @result.environment.display_name
  json.environment_type @result.environment.environment_type
  json.testcase_id @result.testcase_id
  json.testcase_name @result.testcase.name
  json.testcase_validation_id @result.testcase.validation_id
  json.execution_id @result.execution_id
  json.results @result.results
  json.updated_at @result.updated_at
  json.creted_at @result.created_at
end