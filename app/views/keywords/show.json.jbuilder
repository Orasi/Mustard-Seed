json.keyword do
  json.id @keyword.id
  json.keyword @keyword.keyword
  json.project_id @keyword.project_id
  json.created_at @keyword.created_at
  json.updated_at @keyword.updated_at
  json.testcases @keyword.testcases.order(:validation_id, :id) do |tc|
    json.id tc.id
    json.testcase_name tc.name
    json.testcase_id tc.validation_id if tc.validation_id
    json.created_at tc.created_at
    json.updated_at tc.updated_at
    json.version tc.version if tc.version
  end
end