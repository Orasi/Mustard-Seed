class Team < ApplicationRecord

  validates :name, :description, presence: true
  validates :name, uniqueness: true

  has_and_belongs_to_many :users
  has_and_belongs_to_many :projects

end
