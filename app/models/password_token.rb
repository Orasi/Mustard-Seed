class PasswordToken < ApplicationRecord

  belongs_to :user
  has_secure_token :token

  validates :user_id, :expiration, presence: true
  validates :token, uniqueness: true

end
