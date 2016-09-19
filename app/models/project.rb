class Project < ApplicationRecord

  default_scope{ where(deleted: [false, nil])}


  validates :name, presence: true, uniqueness: true

  before_save :generate_key
  after_create :add_execution

  has_many :executions, dependent: :destroy
  has_many :testcases, dependent: :destroy
  has_many :environments, dependent: :destroy
  has_and_belongs_to_many :teams

  private

  def generate_key
    self.api_key = SecureRandom.hex
  end

  def add_execution
    execution = Execution.create(project_id: self.id, closed: false)
    return execution
  end
end
