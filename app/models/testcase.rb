class Testcase < ApplicationRecord

  has_many :steps, dependent: :destroy
  has_many :results, dependent: :destroy

  belongs_to :project

  validates :name, :project_id, presence: true
  validates :name, uniqueness: {scope: :project_id}
  validates :validation_id, uniqueness: {scope: :project_id}, if: 'validation_id.present?'

  scope :not_run, -> (execution){select('testcases.id, testcases.name')
                                      .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                      .where("NOT EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id)")
  }

  scope :failing, -> (execution){select('testcases.id, testcases.name')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'fail')")
  }

  scope :passing, -> (execution){select('testcases.id, testcases.name')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'pass')
                                              AND NOT EXISTS(Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'fail')")
  }

  scope :skip, -> (execution){select('testcases.id, testcases.name')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'skip')
                                              AND NOT EXISTS(Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status IN ('pass', 'fail'))")
  }



end
