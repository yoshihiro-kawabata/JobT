class MessagesController < ApplicationController
    skip_before_action :login_required

    def index
        @messages = Message.where(user_id: current_user.id).order("created_at ASC").page params[:page]        
    end

    def new
          @message = Message.new
          @users = User.all 
    end
  
    def create
        @message = Message.new(message_params)
        touser = User.find(@message.user_id)
        fromuser = User.find(current_user.id)
        @message.create_name = fromuser.name
        @message.create_id = fromuser.id
        @message.user_name = touser.name
        if @message.save
          flash[:notice] = 'メッセージを作成しました'
#          UserMailer.with(to: @user.email, name: @user.name).welcome.deliver_now
          redirect_to ship_messages_path
        else
          @users = User.all 
          render :new
        end
    end

    def show
      @message = Message.find(params[:id])
    end

    def ship
      @messages = Message.where(create_id:current_user.id).order("created_at ASC").page params[:page]        
    end


    private  
      def message_params
        params.require(:message).permit(:user_id, :content)
      end
  


  end
