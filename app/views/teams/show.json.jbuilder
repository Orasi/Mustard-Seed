json.team do
  json.id @team.id
  json.name @team.name
  json.description @team.description
  json.created_at @team.created_at
  json.updated_at @team.updated_at

  json.projects @team.projects do |p|
    json.id p.id
    json.project_name p.name
  end

  json.users @team.users do |u|
    json.id u.id
    json.username u.username
  end
end