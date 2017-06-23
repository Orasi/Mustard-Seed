json.execution do
  json.id @execution.id
  json.name @execution.name
  json.fast true if @execution.fast
  json.project_id @execution.project_id
  json.project_name @execution.project.name
  json.closed @execution.closed

  json.fail @fail do |tc|
    json.id tc.id
    json.validation_id tc.validation_id if tc.validation_id
    json.name tc.name
    json.path "testcases/#{tc.id}"
  end

  json.pass @pass do |tc|
    json.id tc.id
    json.validation_id tc.validation_id if tc.validation_id
    json.name tc.name
    json.path "testcases/#{tc.id}"
  end

  json.skip @skip do |tc|
    json.id tc.id
    json.validation_id tc.validation_id if tc.validation_id
    json.name tc.name
    json.path "testcases/#{tc.id}"
  end

  json.not_run @not_run do |tc|
    json.id tc.id
    json.validation_id tc.validation_id if tc.validation_id
    json.name tc.name
    json.path "testcases/#{tc.id}"
  end

end