class Result < ApplicationRecord

  belongs_to :testcase
  belongs_to :environment, optional: true
  belongs_to :execution, touch: true

  validates :environment_id, :testcase_id, :execution_id, :current_status, presence: true

  def self.statuses
    [:pass, :fail, :error, :complete, :skip, :incomplete, :warning]
  end

  def self.valid_status? new_status
    Result.statuses.include? new_status.downcase.to_sym
  end

  def self.result_types
    [:automated, :manual, :screenshot, :performance]
  end

  def self.valid_type? new_type
    Result.result_types.include? new_type.downcase.to_sym
  end

  def testcase
    Testcase.unscoped{ super }
  end
end
