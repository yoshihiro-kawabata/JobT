class AttendancesController < ApplicationController
    before_action :login_required
    before_action :admin_required, only: [:edit, :update]
    before_action :set_attendance, only: [:show, :edit, :update]
    before_action :set_q, only: [:group, :search]

    def index
        @user = User.find(current_user.id)
        @attendances = Attendance.where(user_id: @user.id).where(attendance_date: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("attendance_date ASC")
        @vacation = Vacation.find_by(user_id: @user.id)
    end

    def show
    end

    def edit
        back_flg = 0
        noticeA = ""

        if @attendance.attendance_date > Date.today
            back_flg += 1
            noticeA += '未来の打刻は修正できません　'
        end

        if @attendance.attendance_date.wday == 0 or @attendance.attendance_date.wday == 6 or HolidayJp.holiday?(@attendance.attendance_date)
            @schedule = Schedule.find_by(schedule_date: @attendance.attendance_date)
            if @schedule.offday?
                back_flg += 1
                noticeA += @attendance.attendance_date.strftime("%Y年%m月%d日") + 'は休みです　'
            end
        end

        if @user.id != current_user.id and @user.admin?
            back_flg += 1
            noticeA += 'ほかの管理者の勤怠打刻は修正できません　'
        end

        if back_flg > 0
            back_attendance
            flash[:notice] = noticeA
        end

    end
  
    def update
        back_flg = 0
        noticeA = ""
        start_timeA = "" + @attendance.attendance_date.to_s + " " + params[:attendance][:start_time].to_s
        end_timeA = "" + @attendance.attendance_date.to_s + " " + params[:attendance][:end_time].to_s

        if @user.id != current_user.id and @user.admin?
            back_flg += 1
            noticeA += 'ほかの管理者の勤怠打刻は修正できません　'
        end

        if start_timeA.to_time > Time.current or end_timeA.to_time > Time.current
            back_flg += 1
            noticeA += '未来の打刻は修正できません　'
        end

        if (params[:attendance][:start_time].present? and params[:attendance][:end_time].present?) and params[:attendance][:start_time] > params[:attendance][:end_time]
            back_flg += 1
            noticeA += '開始時間が終了打刻より遅いです　'
        end

        if params[:attendance][:start_time].blank?
            back_flg += 1
            noticeA += '開始時間が空白です　'
        end

        if params[:attendance][:end_time].blank?
            back_flg += 1
            noticeA += '終了時間が空白です　'
        end

        if params[:attendance][:comment].blank?
            back_flg += 1
            noticeA += 'コメントを入力してください　'
        end

        if back_flg > 0
            flash[:notice] = noticeA
        else
            if @attendance.update(attendance_params)
                noticeA += @attendance.attendance_date.strftime("%Y年%m月%d日") + 'の勤怠を更新しました'
                flash[:notice] = noticeA

                if @user.id != current_user.id
                    @message = Message.new
                    @message.content = @attendance.attendance_date.strftime("%Y年%m月%d日") + 'の勤怠を更新しました。修正者：' + current_user.name + '\n修正日：' + Date.today.strftime('%m月%d日')  + '\n修正後勤怠時刻：' + @attendance.start_time + '～' + @attendance.end_time + '\nコメント：' + @attendance.comment
                    @message.create_name = current_user.name
                    @message.create_id = current_user.id
                    @message.user_name = @user.name
                    @message.user_id = @user.id
                    @message.save         
                end
            end
        end
        back_attendance
    end

    def group
        @users = User.where(group: current_user.group).order("id ASC")
        users = User.where(group: current_user.group).count
        @attendances = []

        @users.each do |user|
            @attendances << @q.result.where(user_id: user.id).where(attendance_date: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("attendance_date ASC")
        end
    end

            
    def search
        @users = User.where(group: current_user.group).order("id ASC")
        users = User.where(group: current_user.group).count
        @attendances = []
    
        @users.each do |user|
            @attendances << @q.result.where(user_id: user.id).order("attendance_date ASC")
        end  
    end
  

    private
      def set_attendance
        @attendance = Attendance.find(params[:id])
        @user = User.find(@attendance.user_id)
      end

      def attendance_params
        params.require(:attendance).permit(:start_time, :end_time, :comment).merge(edit_flg: true)
      end

      def back_attendance
        redirect_to attendance_path(@attendance.id)
      end

      def set_q
        @q = Attendance.ransack(params[:q])
      end

end
