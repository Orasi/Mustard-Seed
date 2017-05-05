class CreateKeywordsTestcases < ActiveRecord::Migration[5.0]
  def change
    create_table :keywords_testcases do |t|
      t.integer :keyword_id
      t.integer :testcase_id
    end
  end
end
