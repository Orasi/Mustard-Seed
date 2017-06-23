class UpdateTestcaseWithKeywordsToVersion5 < ActiveRecord::Migration
  def change
    update_view :testcase_with_keywords, version: 5, revert_to_version: 4
  end
end
