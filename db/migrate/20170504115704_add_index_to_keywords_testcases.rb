class AddIndexToKeywordsTestcases < ActiveRecord::Migration[5.0]
  def change
    add_column :keywords_testcases, :id, :primary_key
  end
end
