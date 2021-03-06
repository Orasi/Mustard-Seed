
json.testcase do
  json.id @testcase.id
  json.testcase_name @testcase.name
  json.validation_id @testcase.validation_id
  json.project_id @testcase.project_id
  json.execution_id @execution_id
  json.reproduction_steps @testcase.reproduction_steps

  if @results.find_by_environment_id(-1)
    json.manual_results @results.find_by_environment_id(-1).results do |r|
      json.id  @results.find_by_environment_id(-1).id
      json.created_by_name r['created_by_name']
      json.created_by_id r['created_by_id']
      json.created_at r['created_at']
      json.result_type r['result_type']
      json.screenshot_id r['screenshot_id'] if r['screenshot_id']
      json.comment r['comment']
      json.status r['status']

    end
  else
    json.manual_results []
  end

  json.automated_results @results.where.not(environment_id: -1).order(:current_status, 'environments.uuid') do |r|
    json.id r.id
    json.environment_id r.environment_id
    json.environment_name r.environment.name unless r.environment_id == -1
    json.environment_type r.environment.environment_type unless r.environment_id == -1
    json.result_type r.results.first['result_type'] if r.results.first['result_type']
    json.comment r.results.first['comment'] if r.results.first['comment']
    json.stacktrace r.results.first['stacktrace'] if r.results.first['stacktrace']
    json.link r.results.first['link'] if r.results.first['link']
    json.screenshot_id r.results.first['screenshot_id'] if r.results.first['screenshot_id']
    json.step_log r.results.first['step_log'] if r.results.first['step_log']
    json.created_at r.updated_at
    json.created_by_name r.results.first['created_by_name'] if r.results.first['created_by_name']
    json.created_by_id r.results.first['created_by_id'].to_s if r.results.first['created_by_id']
    json.status r.current_status
  end

end