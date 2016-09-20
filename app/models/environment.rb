class Environment < ApplicationRecord

  default_scope{ where(deleted: [false, nil])}

  belongs_to :project
  has_many :results, dependent: :destroy

  validates :uuid, presence: true, uniqueness: {scope: :project_id}
  validates :project_id, presence: true

end
