class DownloadToken < ApplicationRecord

  belongs_to :screenshot
  has_secure_token :token

  validates :path, :filename, :disposition, :expiration, :content_type, presence: true
  validates :token, uniqueness: true


end
