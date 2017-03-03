json.success @success do |s|
  json.validation_id s.validation_id
  json.name s.name
  json.reproduction_steps s.reproduction_steps
  json.version s.version
end

json.failure @error
