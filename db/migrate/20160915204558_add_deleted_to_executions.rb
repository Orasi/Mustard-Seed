class AddDeletedToExecutions < ActiveRecord::Migration[5.0]
  def change
    add_column :executions, :deleted, :boolean
  end
end
