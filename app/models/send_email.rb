class SendEmail
    require 'sendgrid-ruby'
    include SendGrid
  
    def self.test_email
      from = Email.new(email: 'jobtowner312@gmail.com')
      to = Email.new(email: 'yoshihiro_kawabata@mediado.jp')
      subject = 'OK1'
      content = Content.new(type: 'text/plain', value: 'OK2')
      mail = Mail.new(from, subject, to, content)
  
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_WEB_API_KEY'])
      response = sg.client.mail._('send').post(request_body: mail.to_json)
    end
  end