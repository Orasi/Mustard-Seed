class AddDefaultToTestcaseCount < ActiveRecord::Migration[5.0]
  def change
    change_column :keywords, :testcase_count, :integer, :default => 0

  end
end
