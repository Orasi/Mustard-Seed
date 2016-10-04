class ScreenshotToken < ApplicationRecord

  belongs_to :screenshot
  has_secure_token :token

  validates :screenshot_id, :expiration, presence: true
  validates :token, uniqueness: true


end
