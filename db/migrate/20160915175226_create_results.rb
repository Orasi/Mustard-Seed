class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|

      t.timestamps
      t.string 'result_type'
      t.integer 'environment_id'
      t.integer 'testcase_id'
      t.string 'status'
      t.text 'comment'
      t.json 'options'
    end
  end
end
