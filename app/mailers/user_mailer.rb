class UserMailer < ApplicationMailer
    def welcome
        @name = params[:name]
        
        mail(to: params[:to], subject: "登録完了")
      end

      def send_signup_email(user)
        @user = user
        mail( :to => @user.email,
        :subject => 'Thanks for signing up for our amazing app' )
      end
end
