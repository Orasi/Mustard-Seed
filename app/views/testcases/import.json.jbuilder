json.success @success do |s|
  json.id s.id
  json.name s.name
  json.reproduction_steps s.reproduction_steps
end

json.error @error
