class ReportsController < ApplicationController
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
    end
      
    def new
      repo_check = Report.find_by(user_id:current_user.id, createdate: Date.today.strftime("%m月%d日"))
      if repo_check.nil?
        @report = Report.new
      else
        redirect_to edit_report_path(repo_check.id), notice: '今日の日報は既に作成しています。'
      end
    end
      
    def edit
    end
      
    def create
      @report = Report.new(report_params)
      userA = User.find(current_user.id)

      @report.user_id = userA.id
      @report.user_name = userA.name
      @report.group = userA.group

      if @report.save
        redirect_to @report, notice: '日報を作成しました。'
      else
        render :new
      end
    end
      
    def update
      if @report.update(report_params)
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
