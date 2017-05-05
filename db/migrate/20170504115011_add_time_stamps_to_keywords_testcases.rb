class AddTimeStampsToKeywordsTestcases < ActiveRecord::Migration[5.0]
  def change
    add_column(:keywords_testcases, :created_at, :datetime)
    add_column(:keywords_testcases, :updated_at, :datetime)
  end
end
