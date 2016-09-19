json.teams @teams do |t|
  json.id t.id
  json.name t.name
  json.description t.description
  json.user_count t.users.count
  json.project_count t.projects.count
  json.created_at t.created_at
  json.updated_at t.updated_at
end
