class CreateTestcases < ActiveRecord::Migration[5.0]
  def change
    create_table :testcases do |t|
      t.string 'name'
      t.integer 'validation_id'
      t.integer 'project_id'
      t.datetime 'runner_touch'
      t.boolean 'locked'
      t.timestamps
    end
  end
end
