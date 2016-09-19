class User < ApplicationRecord

  has_secure_password

  validates :first_name, :last_name, :password_digest, :username,  presence: true
  validates :username, :uniqueness => true

  default_scope{ where(deleted: [false, nil])}

  has_one :user_token, dependent: :destroy
  has_and_belongs_to_many :teams

  def self.find_by_user_token(token)
    user_token = UserToken.find_by_token(token)
    if user_token
      return user_token.user
    else
      return nil
    end
  end

  def projects
    if admin
      return Project.all
    else
      projects = []
      self.teams.each do |t|
        projects.append(t.projects)
      end
      return projects.uniq
    end
  end

end
