class AddExecutionIdToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :execution_id, :integer
  end
end
