class SchedulesController < ApplicationController
    before_action :login_required
    skip_before_action :admin_required
    before_action :set_schedule, only: [:show, :edit, :update]
    before_action :set_q, only: [:index, :search]
        
    def index
      @users = User.where(group: current_user.group).order("id ASC")
      users = User.where(group: current_user.group).count
      @schedules = []

      @users.each do |user|
        @schedules << @q.result.where(user_id: user.id).where(schedule_date: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("schedule_date ASC")
      end
    end
      
    def show
        @user = User.find(@schedule.user_id)
    end
                  
    def search
        @users = User.where(group: current_user.group).order("id ASC")
        users = User.where(group: current_user.group).count
        @schedules = []
  
        @users.each do |user|
          @schedules << @q.result.where(user_id: user.id).order("schedule_date ASC")
        end  
    end

    def edit

      back_flg = 0
      noticeA = ""

      if @user.id != current_user.id and @user.admin?
          back_flg += 1
          noticeA += 'ほかの管理者のスケジュールは修正できません　'
      end

      if back_flg > 0
        redirect_to schedule_path(@schedule.id)
        flash[:notice] = noticeA
      end

    end
  
    def update
      back_flg = 0
      noticeA = ""

      if params[:schedule][:offday] == "true"

        if params[:schedule][:status].blank?
          back_flg += 1
          noticeA += 'ステータスが空白です　'
        end

        if params[:schedule][:comment].blank?
          back_flg += 1
          noticeA += 'コメントを入力してください　'
        end

      else
  
        if (params[:schedule][:start_time].present? and params[:schedule][:end_time].present?) and params[:schedule][:start_time] > params[:schedule][:end_time]
          back_flg += 1
          noticeA += '開始時間が終了時間より遅いです　'
        end
  
        if params[:schedule][:status].blank?
          back_flg += 1
          noticeA += 'ステータスが空白です　'
        end
  
        if params[:schedule][:start_time].blank?
          back_flg += 1
          noticeA += '開始時間が空白です　'
        end
  
        if params[:schedule][:end_time].blank?
          back_flg += 1
          noticeA += '終了時間が空白です　'
        end
  
        if (params[:schedule][:start_time].present? and params[:schedule][:end_time].present?) and params[:schedule][:start_time] == params[:schedule][:end_time]
          back_flg += 1
          noticeA += '開始時間が終了時間と同じです　'
        end
    
      end

      
      if back_flg > 0
        flash[:notice] = noticeA
        render :edit
      else
        if @schedule.update(schedule_params)
            noticeA += @schedule.schedule_date.strftime("%Y年%m月%d日") + 'の予定を更新しました'
            flash[:notice] = noticeA
 
            if @user.id != current_user.id
                @message = Message.new
                if @schedule.offday?
                  @message.content = @schedule.schedule_date.strftime("%Y年%m月%d日") + 'のスケジュールを更新しました。修正者：' + current_user.name + '\n修正日：' + Date.today.strftime('%m月%d日')  + '\n勤怠予定：欠席\nコメント：' + @schedule.comment
                else
                  @message.content = @schedule.schedule_date.strftime("%Y年%m月%d日") + 'のスケジュールを更新しました。修正者：' + current_user.name + '\n修正日：' + Date.today.strftime('%m月%d日')  + '\n勤怠予定：出席\n修正後スケジュール時刻：' + @schedule.start_time + '～' + @schedule.end_time + '\nコメント：' + @schedule.comment
                end
                @message.create_name = current_user.name
                @message.create_id = current_user.id
                @message.user_name = @user.name
                @message.user_id = @user.id
                @message.save         
            end

            redirect_to schedule_path(@schedule.id)

        else
            flash[:notice] = 'スケジュールを更新できませんでした'
            render :edit    
        end
      end
    end
  
  private
      def set_schedule
        @schedule = Schedule.find(params[:id])
        @user = User.find(@schedule.user_id)
      end

      def schedule_params
        params.require(:schedule).permit(:start_time, :end_time, :offday, :status, :comment)
      end        

      def set_q
        @q = Schedule.ransack(params[:q])
      end

end
