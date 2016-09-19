json.users @users do |u|
  json.id u.id
  json.username u.username
  json.first_name u.first_name
  json.last_name u.last_name
  json.company u.company
  json.admin u.admin
  json.created_at u.created_at
  json.updated_at u.updated_at
end
