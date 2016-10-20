class Testcase < ApplicationRecord

  serialize :reproduction_steps

  has_many :results, dependent: :destroy

  belongs_to :project

  validates :name, :project_id, presence: true
  validates :name, uniqueness: {scope: :project_id}
  validates :validation_id, uniqueness: {scope: :project_id}, if: 'validation_id.present?'

  scope :not_run, -> (execution){select('testcases.id, testcases.name, testcases.runner_touch, testcases.validation_id')
                                      .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                      .where("NOT EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.execution_id = executions.id)")
  }

  scope :failing, -> (execution){select('testcases.id, testcases.name, testcases.validation_id')
                                     .joins("JOIN executions ON executions.project_id = testcases.project_id \
                                                AND executions.id = #{execution.id} ")
                                     .where("EXISTS (Select current_status from results \
                                                          WHERE results.testcase_id = testcases.id \
                                                              AND results.current_status = 'fail' \
                                                              AND results.execution_id = executions.id)")
  }

  scope :passing, -> (execution){select('testcases.id, testcases.name, testcases.validation_id')
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

  scope :skip, -> (execution){select('testcases.id, testcases.name, testcases.validation_id')
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



end
