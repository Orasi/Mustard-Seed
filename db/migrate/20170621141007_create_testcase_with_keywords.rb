class CreateTestcaseWithKeywords < ActiveRecord::Migration
  def change
    create_view :testcase_with_keywords
  end
end
