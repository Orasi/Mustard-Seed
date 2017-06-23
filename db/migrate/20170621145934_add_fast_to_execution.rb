class AddFastToExecution < ActiveRecord::Migration[5.0]
  def change
    add_column :executions, :fast, :boolean, default: true
  end
end
