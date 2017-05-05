class RemoveIndexesFromKeywordTestcases < ActiveRecord::Migration[5.0]
  def change
    remove_column :keywords_testcases, :id
    add_index :keywords_testcases, [:keyword_id, :testcase_id], unique: true
  end
end
