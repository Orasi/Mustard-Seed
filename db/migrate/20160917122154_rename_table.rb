class RenameTable < ActiveRecord::Migration[5.0]
  def change
    rename_table :teams_projects, :projects_teams
  end
end
