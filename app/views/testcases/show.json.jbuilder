
json.testcase do
  json.id @testcase.id
  json.testcase_name @testcase.name
  json.testcase_id @testcase.validation_id if @testcase.validation_id
  json.project_id @testcase.project_id
  json.created_at @testcase.created_at
  json.updated_at @testcase.updated_at
  json.outdated @testcase.outdated
  json.version @testcase.version if @testcase.version
  json.reproduction_steps @testcase.reproduction_steps if @testcase.reproduction_steps
  json.keywords @testcase.keywords do |keyword|
    json.id keyword.id
    json.keyword keyword.keyword
  end


end
if @other_versions
  json.other_versions @other_versions do |ov|
    json.id ov.id
    json.testcase_name ov.name
    json.testcase_id ov.validation_id if ov.validation_id
    json.project_id ov.project_id
    json.created_at ov.created_at
    json.updated_at ov.updated_at
    json.outdated ov.outdated
    json.version ov.version if ov.version
    json.reproduction_steps ov.reproduction_steps if ov.reproduction_steps
    json.keywords ov.keywords do |keyword|
      json.id keyword.id
      json.keyword keyword.keyword
    end
    json.username ov.username if ov.username
  end
end