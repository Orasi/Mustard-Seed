class Testcase < ApplicationRecord

  serialize :reproduction_steps

  has_many :results, dependent: :destroy
  has_many :keywords_testcases, dependent: :destroy
  has_many :keywords, through: :keywords_testcases
  belongs_to :project

  before_validation :add_version
  before_validation :add_token

  validates :name, :project_id, :token, :version, presence: true
  validates :name, uniqueness: {scope: [:outdated, :project_id]}, unless: 'outdated'

  with_options unless: :outdated do |current|
    current.validates :validation_id, uniqueness: {scope: [:project_id, :outdated]}, if: 'validation_id.present?'
  end

  default_scope { where(outdated: [false, nil]) }
  scope :join_keywords, -> {joins("LEFT OUTER JOIN keywords_testcases ON keywords_testcases.testcase_id = testcases.id")
                            .joins("LEFT OUTER JOIN keywords ON keywords_testcases.keyword_id = keywords.id")}
  scope :with_keywords, -> (keywords){ keywords.blank? ? none : joins("JOIN keywords_testcases ON keywords_testcases.testcase_id = testcases.id")
                                                        .joins("JOIN keywords ON keywords_testcases.keyword_id = keywords.id")
                                                        .where("keywords.keyword in (?)", keywords)
                                                        .group("testcases.id")
                                                        .having("count (*) = ?", keywords.count)}


  scope :as_of_date, -> (tc_date){unscope(where: :outdated).where('"testcases"."created_at" <= ? AND ("testcases"."revised_at" >= ? OR "testcases"."revised_at" IS NULL)', tc_date, tc_date)}
  scope :outdated, -> {unscope(where: :outdated).where(outdated: true)}
  scope :not_run, -> (execution){select('testcases.id, testcases.name, testcases.validation_id, testcases.reproduction_steps')
                                      .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                      .where("NOT EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.execution_id = executions.id)")
  }

  scope :not_run_with_environment, -> (execution, environment){select('testcases.id, testcases.name, testcases.validation_id, testcases.reproduction_steps')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("NOT EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.execution_id = executions.id
                                                              AND results.environment_id= #{environment.id})")
  }

  scope :failing, -> (execution){select('testcases.id, testcases.name, testcases.validation_id, testcases.reproduction_steps')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'fail' \
                                                              AND results.execution_id = executions.id)")
  }

  scope :passing, -> (execution){select('testcases.id, testcases.name, testcases.validation_id, testcases.reproduction_steps')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'pass' \
                                                              AND results.execution_id = executions.id)\
                                              AND NOT EXISTS(Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'fail'
                                                              AND results.execution_id = executions.id)")
  }

  scope :skip, -> (execution){select('testcases.id, testcases.name, testcases.validation_id, testcases.reproduction_steps')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'skip'\
                                                              AND results.execution_id = executions.id)\
                                              AND NOT EXISTS(Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status IN ('pass', 'fail')\
                                                              AND results.execution_id = executions.id)")
  }

  def add_version
    if  version.blank?
      self.version = 1
    end
  end

  def add_token
    if token.blank?
      self.token = Testcase.generate_unique_secure_token
    end
  end

  def close!
    self.update!(outdated: true)
    self.update!(revised_at: DateTime.now)
  end

end
