class UserToken < ApplicationRecord

  scope :of_token_type, ->(t_type) { where(token_type: t_type) }

  belongs_to :user
  has_secure_token :token

  validates :user_id, :expires, :token_type, presence: true
  validates :token, uniqueness: {scope: :token_type}
  validates :token_type, inclusion: { in: %w(web extension),  message: "%{value} is not a valid token type" }


  def self.token_expiration_by_type(t_type)
    if t_type == :web
      return DateTime.now + 2.hours
    elsif t_type == :extension
      return DateTime.now + 1.day
    end
  end

end
