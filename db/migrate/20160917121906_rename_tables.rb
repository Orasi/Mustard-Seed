class RenameTables < ActiveRecord::Migration[5.0]
  def change
    rename_table :users_teams, :teams_users
  end
end
