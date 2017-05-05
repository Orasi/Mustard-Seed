class Keyword < ApplicationRecord

  belongs_to :project
  has_many :keywords_testcases, dependent: :destroy
  has_many :testcases, through: :keywords_testcases

  validates :project_id, :keyword, presence: true
  validates :keyword, uniqueness: {scope: :project_id}

  before_validation :convert_keyword_to_upcase

  def convert_keyword_to_upcase
    self.keyword.upcase! if keyword
  end

  def update_testcase_count
    self.update_columns  testcase_count: self.testcases.count
  end

end
