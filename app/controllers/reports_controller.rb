class ReportsController < ApplicationController
    before_action :login_required
    skip_before_action :admin_required
    before_action :set_report, only: [:show, :edit, :update]
    before_action :set_q, only: [:index, :search]
        
    def index
      @user = User.find(current_user.id)
      if admin_user?
        @reports = @q.result.where(group:@user.group).where(createdate: Date.today.strftime("%m月%d日")).order("user_id ASC,created_at ASC")
      else
        @reports = @q.result.where(user_id:current_user.id).where(created_at: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("user_id ASC,created_at ASC")
      end
    end
      
    def show
      user = User.find(@report.user_id)
      @group = Group.find(user.group)
    end
      
    def new
      @schedule = Schedule.find_by(user_id: current_user.id, schedule_date: Date.today)
      if @schedule.offday?
          if current_user.admin?
              flash[:notice] = '今日の予定は欠席です。出勤する場合は「スケジュール」から今日の勤怠予定を「出席」に変更してください。'
          else
              flash[:notice] = '今日の予定は欠席です。出勤する場合は「休日出勤スケジュール変更申請」を申請してください。'
          end
          redirect_to jobs_home_path        
      else
        user = User.find(current_user.id)
        @group = Group.find(user.group)

        repo_check = Report.find_by(user_id:current_user.id, createdate: Date.today.strftime("%m月%d日"))
        attend_check = Attendance.find_by(user_id: current_user.id, attendance_date: Date.today)

        if attend_check.start_time.nil?
           redirect_to jobs_home_path, notice: 'まだ出勤していません。'
        else
          if repo_check.nil?
             @report = Report.new
          else
            redirect_to edit_report_path(repo_check.id), notice: '今日の日報は既に作成しています。'
          end
        end
      end
    end
      
    def edit
      user = User.find(@report.user_id)
      @group = Group.find(user.group)
    end
      
    def create
      @report = Report.new(report_params)
      userA = User.find(current_user.id)

      @report.user_id = userA.id
      @report.user_name = userA.name
      @report.group = userA.group

      if @report.save

        @users = User.where(group: current_user.group, admin:true)
        @users.each do |user|
          @message = Message.new
          @message.content = "日報を作成しました。　作成日：" + @report.createdate
          @message.create_name = current_user.name
          @message.create_id = current_user.id
          @message.user_name = user.name
          @message.user_id = user.id
          @message.save
        end
        redirect_to @report, notice: '日報を作成しました。'
      else
        render :new
      end
    end
      
    def update
      if @report.update(report_params)
        if admin_user?
          @user = User.find(@report.user_id)
          @message = Message.new
          @message.content = "管理者コメントを追記しました。　追記日：" + @report.createdate
          @message.create_name = current_user.name
          @message.create_id = current_user.id
          @message.user_name = @user.name
          @message.user_id = @user.id
          @message.save
        end
        redirect_to @report, notice: '日報を編集しました。'
      else
        render :edit
      end
    end
      
    def search
      @user = User.find(current_user.id)
      if admin_user?
        @reports = @q.result.where(group:@user.group).order("user_id ASC,created_at ASC")
      else
        @reports = @q.result.where(user_id:current_user.id).order("user_id ASC,created_at ASC")
      end
    end
      
    private
      def set_report
        @report = Report.find(params[:id])
      end
      
      def report_params
        params.require(:report).permit(:daytask, :emotion, :learn, :transition, :admincom, :createdate)
      end
      
      def set_q
        @q = Report.ransack(params[:q])
      end

end
