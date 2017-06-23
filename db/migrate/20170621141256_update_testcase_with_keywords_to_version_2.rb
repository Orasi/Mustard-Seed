class UpdateTestcaseWithKeywordsToVersion2 < ActiveRecord::Migration
  def change
    update_view :testcase_with_keywords, version: 2, revert_to_version: 1
  end
end
