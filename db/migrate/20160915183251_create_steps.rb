class CreateSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :steps do |t|

      t.timestamps
      t.integer 'testcase_id'
      t.integer 'step_number'
      t.text 'action'
      t.text 'expected'
    end
  end
end
