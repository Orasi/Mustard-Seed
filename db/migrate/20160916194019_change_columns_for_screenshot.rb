class ChangeColumnsForScreenshot < ActiveRecord::Migration[5.0]
  def change
    remove_column :screenshots, :execution_id, :integer
    remove_column :screenshots, :testcase_id, :integer
    remove_column :screenshots, :environment_id, :integer
    add_column :screenshots, :execution_start, :date
    add_column :screenshots, :testcase_name, :string
    add_column :screenshots, :environment_uuid, :string

  end
end
