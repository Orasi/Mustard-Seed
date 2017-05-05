class KeywordsTestcase < ApplicationRecord

  belongs_to :keyword
  belongs_to :testcase

  validates :keyword_id, presence: true, uniqueness: {scope: :testcase_id}
  validates :testcase_id, presence: true
  validate :belong_to_same_project

  after_create :increment_test_count

  def belong_to_same_project
    if testcase.project != keyword.project
      errors[:base] << "Testcase project does not match keyword projects"
    end
  end

  def increment_test_count
    keyword.update(testcase_count: keyword.testcase_count + 1)
  end
end
