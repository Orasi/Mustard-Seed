class UpdateTestcaseWithKeywordsToVersion4 < ActiveRecord::Migration
  def change
    update_view :testcase_with_keywords, version: 4, revert_to_version: 3
  end
end
