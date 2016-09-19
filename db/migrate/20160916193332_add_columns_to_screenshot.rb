class AddColumnsToScreenshot < ActiveRecord::Migration[5.0]
  def change
    add_column :screenshots, :execution_id, :integer
    add_column :screenshots, :testcase_id, :integer
    add_column :screenshots, :environment_id, :integer
    remove_column :screenshots, :result_id

  end
end
