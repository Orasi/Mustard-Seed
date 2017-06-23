class UpdateTestcaseWithKeywordsToVersion3 < ActiveRecord::Migration
  def change
    update_view :testcase_with_keywords, version: 3, revert_to_version: 2
  end
end
