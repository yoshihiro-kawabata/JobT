class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.smtp_user_name
  layout 'mailer'
end
