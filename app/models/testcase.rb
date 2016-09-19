class Testcase < ApplicationRecord

  has_many :steps, dependent: :destroy
  has_many :results, dependent: :destroy

  belongs_to :project

  validates :name, :project_id, presence: true
  validates :name, uniqueness: {scope: :project_id}
  validates :validation_id, uniqueness: {scope: :project_id}, if: 'validation_id.present?'


end
