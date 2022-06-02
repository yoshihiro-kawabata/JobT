class MessagesController < ApplicationController
    before_action :set_message, only: [:show, :destroy]
    before_action :login_required
    skip_before_action :admin_required

    def index
        @messages = Message.where(user_id: current_user.id).order("created_at DESC").page params[:page]        
    end

    def new
          @message = Message.new
          @users = User.where.not(id: current_user.id).order("id ASC")
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
          redirect_to ship_messages_path
        else
          @users = User.where.not(id: current_user.id).order("id ASC")
          render :new
        end
    end

    def show
    end

    def ship
      @messages = Message.select(:id,:user_name,:content).where(create_id:current_user.id).order("created_at DESC").page params[:page]        
    end

    def destroy
      @message.destroy
      redirect_to messages_path, notice: 'メッセージを削除しました'
    end  

    def alldel
      @messages = Message.where(id: params[:mes]).delete_all
      redirect_to messages_path, notice: '受信メッセージを削除しました'
    end  

    def alldel_ship
      @messages = Message.where(id: params[:mes]).delete_all
      redirect_to ship_messages_path, notice: '送信メッセージを削除しました'
    end  

    private  
      def message_params
        params.require(:message).permit(:user_id, :content)
      end

      def set_message
        @message = Message.find(params[:id])        
      end
  end
