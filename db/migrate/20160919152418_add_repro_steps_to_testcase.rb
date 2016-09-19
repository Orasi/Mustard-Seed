class AddReproStepsToTestcase < ActiveRecord::Migration[5.0]
  def change
    add_column :testcases, :reproduction_steps, :json
  end
end
