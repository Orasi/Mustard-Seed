json.results @results do |result|
  json.id result.id
  json.environment_id result.environment_id
  json.environment_display_name result.environment.display_name if result.environment
  json.environment_type result.environment.environment_type if result.environment
  json.testcase_id result.testcase_id
  json.testcase_name result.testcase.name
  json.testcase_validation_id result.testcase.validation_id
  json.execution_id result.execution_id
  json.project_id result.execution.project_id
  json.project_name result.execution.project.name
  json.result result.results[0]
  json.updated_at result.updated_at
end