class Environment < ApplicationRecord

  # scope :summary, -> (execution){select('environments.uuid.id, testcases.name')
  #                                    .joins("JOIN executions ON executions.project_id = testcases.project_id \
  #                                               AND executions.id = #{execution.id} ")
  #                                    .where("NOT EXISTS (Select current_status from results \
  #                                                         WHERE results.testcase_id = testcases.id \
  #                                                             AND results.execution_id = executions.id)")
  # }

  belongs_to :project
  has_many :results, dependent: :destroy
  before_save :default_values
  validates :uuid, presence: true, uniqueness: {scope: :project_id}
  validates :project_id, presence: true


  def default_values

    self.environment_type ||= 'Undefined'
  end

  # def display_name
  #
  #   return uuid unless options
  #
  #   if options['manufacturer'] && options['model'] && options['os_version']
  #     return "#{options['manufacturer']} - #{options['model']} - #{options['os_version']}"
  #   elsif options['os'] && options['browser'] && options['browser_version']
  #     return "#{options['os']} - #{options['browser']} - #{options['browser_version']}"
  #   end
  #
  #   uuid
  # end
end
