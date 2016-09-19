class UserToken < ApplicationRecord

  belongs_to :user
  has_secure_token :token

  validates :user_id, :expires, presence: true
  validates :token, uniqueness: true

end
