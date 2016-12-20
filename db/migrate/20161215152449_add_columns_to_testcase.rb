class AddColumnsToTestcase < ActiveRecord::Migration[5.0]
  def change
    add_column :testcases, :outdated, :boolean
    add_column :testcases, :version, :integer
    add_column :testcases, :token, :string
  end
end
