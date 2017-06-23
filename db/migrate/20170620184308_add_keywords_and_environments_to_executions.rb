class AddKeywordsAndEnvironmentsToExecutions < ActiveRecord::Migration[5.0]
  def change
    add_column :executions, :active_keywords, :integer, array: true
    add_column :executions, :active_environments, :integer, array: true
  end
end
