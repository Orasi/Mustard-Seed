class Execution < ApplicationRecord

  default_scope{ where(deleted: [false, nil])}
  scope :open_execution, ->() { find_by_closed(false) }

  belongs_to :project
  has_many :results, dependent: :destroy
end
