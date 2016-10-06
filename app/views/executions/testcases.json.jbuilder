json.execution do
  json.id @execution.id
  json.project_id @execution.project_id
  json.project_name @execution.project.name
  json.closed @execution.closed

  json.fail @fail do |tc|
    json.id tc.id
    json.name tc.name
  end

  json.fail @fail do |tc|
    json.id tc.id
    json.name tc.name
    json.path "results/#{tc.id}"
  end

  json.pass @pass do |tc|
    json.id tc.id
    json.name tc.name
    json.path "results/#{tc.id}"
  end

  json.skip @skip do |tc|
    json.id tc.id
    json.name tc.name
    json.path "results/#{tc.id}"
  end

  json.not_run @not_run do |tc|
    json.id tc.id
    json.name tc.name
    json.path "results/#{tc.id}"
  end

end