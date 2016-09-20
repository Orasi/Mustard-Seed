json.execution do
  json.id @execution.id
  json.project_id @execution.project_id
  json.closed @execution.closed

  json.fail @fail do |tc|
    json.id tc.id
    json.name tc.name
  end

  json.fail @fail do |tc|
    json.id tc.id
    json.name tc.name
  end

  json.pass @pass do |tc|
    json.id tc.id
    json.name tc.name
  end

  json.skip @skip do |tc|
    json.id tc.id
    json.name tc.name
  end

  json.not_run @not_run do |tc|
    json.id tc.id
    json.name tc.name
  end

end