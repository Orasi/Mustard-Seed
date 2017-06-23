class TestcaseWithKeyword < ApplicationRecord

  default_scope { where(outdated: [false, nil]) }
  scope :as_of_date, -> (tc_date = Date.today){unscope(where: :outdated).where('"testcase_with_keywords"."created_at" <= ? AND ("testcase_with_keywords"."revised_at" >= ? OR "testcase_with_keywords"."revised_at" IS NULL)', tc_date, tc_date)}
  scope :outdated, -> {unscope(where: :outdated).where(outdated: true)}
end
