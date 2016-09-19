class UpdateIndexes < ActiveRecord::Migration[5.0]
  def change
    remove_column :projects_teams, :id
    add_index :projects_teams, [:team_id, :project_id], unique: true

    remove_column :teams_users, :id
    add_index :teams_users, [:user_id, :team_id], unique: true
  end
end
