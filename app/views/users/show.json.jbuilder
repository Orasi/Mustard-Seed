json.user do
  json.id @user.id
  json.username @user.username
  json.email @user.email
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.company @user.company
  json.admin @user.admin
  json.created_at @user.created_at
  json.updated_at @user.updated_at
end
