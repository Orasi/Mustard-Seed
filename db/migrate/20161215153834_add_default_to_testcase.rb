class AddDefaultToTestcase < ActiveRecord::Migration[5.0]
  def change
    change_column_default :testcases, :outdated, :false
    change_column_default :testcases, :version, 1
  end
end
