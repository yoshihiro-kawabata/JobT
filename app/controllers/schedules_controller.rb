class SchedulesController < ApplicationController
    before_action :login_required
    skip_before_action :admin_required
    before_action :set_schedule, only: [:show, :edit, :update]
    before_action :set_q, only: [:index, :search]
        
    def index
      @users = User.where(group: current_user.group).order("id ASC")
      users = User.where(group: current_user.group).count
      @schedules = []

      users.times do |n|
        @schedules << @q.result.where(user_id: "#{n}").where(schedule_date: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("schedule_date ASC")
      end

    end
      
    def show
        @user = User.find(@schedule.user_id)
    end
                  
    def search
        @users = User.where(group: current_user.group).order("id ASC")
        users = User.where(group: current_user.group).count
        @schedules = []
  
        users.times do |n|
          @schedules << @q.result.where(user_id: "#{n}").order("schedule_date ASC")
        end  
    end

    def edit
    end
  
    def update
      back_flg = 0
      noticeA = ""

      if @schedule.schedule_date.wday == 0 or @schedule.schedule_date.wday == 6 or HolidayJp.holiday?(@schedule.schedule_date) or @schedule.offday?
        back_flg += 1
        noticeA += @schedule.schedule_date.strftime("%Y年%m月%d日") + 'は休みです'
      end

      if params[:schedule][:start_time] > params[:schedule][:end_time]
        back_flg += 1
        noticeA += '開始時間が終了打刻より遅いです　'
      end

      if params[:schedule][:comment].blank?
        back_flg += 1
        noticeA += 'コメントを入力してください'
      end

      if back_flg > 0
        flash[:notice] = noticeA
      else
        if @schedule.update(schedule_params)
            noticeA += @schedule.schedule_date.strftime("%Y年%m月%d日") + 'の予定を更新しました'
            flash[:notice] = noticeA
 
            if @user.id != current_user.id
                @message = Message.new
                @message.content = @schedule.schedule_date.strftime("%Y年%m月%d日") + 'のスケジュールを更新しました。修正者：' + current_user.name + '\n修正日：' + Date.today.strftime('%m月%d日%H時%M分')  + '\n修正後スケジュール時刻：' + @schedule.start_time + '～' + @schedule.end_time + '\nコメント：' + @schedule.comment
                @message.create_name = current_user.name
                @message.create_id = current_user.id
                @message.user_name = @user.name
                @message.user_id = @user.id
                @message.save         
            end
        end
      end
      redirect_to schedule_path(@schedule.id)
    end

  private
      def set_schedule
        @schedule = Schedule.find(params[:id])
        @user = User.find(@schedule.user_id)
      end

      def schedule_params
        params.require(:schedule).permit(:start_time, :end_time, :status, :comment)
      end        

      def set_q
        @q = Schedule.ransack(params[:q])
      end

end
