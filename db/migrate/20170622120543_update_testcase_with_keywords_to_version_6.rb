class UpdateTestcaseWithKeywordsToVersion6 < ActiveRecord::Migration
  def change
    update_view :testcase_with_keywords, version: 6, revert_to_version: 5
  end
end
