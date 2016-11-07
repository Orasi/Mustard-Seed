class PasswordMailer < ApplicationMailer


  def welcome_email(user, url)
    @username = "#{user.first_name} #{user.last_name}"
    @url  = url
    mail(to: @user.username, subject: 'Welcome to Mustard')
  end

  def reset_password(user, url)
    @username = "#{user.first_name} #{user.last_name}"
    @url  = url

    mail(to: user.username, subject: 'Mustard Password Reset')
  end

end
