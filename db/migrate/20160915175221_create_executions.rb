class CreateExecutions < ActiveRecord::Migration[5.0]
  def change
    create_table :executions do |t|

      t.timestamps
      t.integer 'project_id'
      t.boolean 'closed'
      t.datetime 'closed_at'
    end
  end
end
