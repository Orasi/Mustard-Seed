class AddNameToExecutions < ActiveRecord::Migration[5.0]
  def change
    add_column :executions, :name, :string
  end
end
