class ApplicationMailer < ActionMailer::Base
  default from: 'mailer@localhost.localdomain'
  layout 'mailer'
end
