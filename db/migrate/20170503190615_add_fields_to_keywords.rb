class AddFieldsToKeywords < ActiveRecord::Migration[5.0]
  def change
    add_column :keywords, :project_id, :integer
    add_column :keywords, :testcase_count, :integer
  end
end
