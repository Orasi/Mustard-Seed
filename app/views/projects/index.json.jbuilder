json.projects @projects do |p|
  json.id p.id
  json.project_name p.name
  json.api_key p.api_key
  json.created_at p.created_at
  json.updated_at p.updated_at
end