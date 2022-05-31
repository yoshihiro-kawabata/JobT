class Mail::SendGrid
    def initialize(settings)
      @settings = settings
    end
  
    def deliver!(mail)
      sg_mail = set_mail_information(mail)
      add_content_and_category(sg_mail, mail)
      sg = SendGrid::API.new(api_key: @settings[:api_key])
      sg.client.mail._('send').post(request_body: sg_mail.to_json)
    end
  
    private
  
      def set_mail_information(mail)
        from = SendGrid::Email.new(email: mail.from.first)
        to = SendGrid::Email.new(email: mail.to.first)
        subject = mail.subject
        content = SendGrid::Content.new(type: 'text/plain', value: mail.body.parts[0].body.raw_source)
        SendGrid::Mail.new(from, subject, to, content)
      end
  
      def add_content_and_category(sg_mail, mail)
        sg_mail.add_content(SendGrid::Content.new(type: 'text/html', value: mail.body.parts[1].body.raw_source))
        sg_mail.add_category(SendGrid::Category.new(name: mail[:category].value))
      end
  end