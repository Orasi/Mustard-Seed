json.testcase do
  json.id @testcase.id
  json.validation_id @testcase.validation_id
  json.reproduction_steps @testcase.reproduction_steps

  json.results @results do |r|
    json.id r.id
    json.environment_id r.environment_id
    json.environment_name r.environment.uuid
    json.result_type r.results.first['result_type'] if r.results.first['result_type']
    json.comment r.results.first['comment'] if r.results.first['comment']
    json.stacktrace r.results.first['stacktrace'] if r.results.first['stacktrace']
    json.link r.results.first['link'] if r.results.first['link']
    json.screenshot r.results.first['screenshot'] if r.results.first['screenshot']
    json.name r.current_status
  end

end