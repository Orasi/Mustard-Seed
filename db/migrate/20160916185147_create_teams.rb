class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|

      t.timestamps
      t.string :name
      t.integer :team_owner
      t.text :description


    end

    create_table :teams_projects do |t|
      t.timestamps
      t.integer :team_id
      t.integer :project_id
    end

    create_table :users_teams do |t|
      t.timestamps
      t.integer :team_id
      t.integer :user_id
    end
  end
end
