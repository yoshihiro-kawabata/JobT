class JobsController < ApplicationController
    before_action :login_required
    before_action :set_q, only: [:post, :data]

    def home
        @user = User.find(current_user.id)
        @attendance = Attendance.find_by(user_id: @user.id, attendance_date: Date.today)
        @schedule = Schedule.find_by(user_id: @user.id, schedule_date: Date.today)
    end

    def attend
        @attendance = Attendance.find_by(user_id: current_user.id, attendance_date: Date.today)
        if @attendance.start_time.nil?
            @attendance.update(start_time: DateTime.current.strftime('%H:%M'))
            flash[:notice] = '出勤打刻しました'        
            redirect_to jobs_home_path
            else
            flash[:alert] = '既に出勤打刻しています。'
            redirect_to jobs_home_path        
        end
    end

    def leave
        @attendance = Attendance.find_by(user_id: current_user.id, attendance_date: Date.today)
        if @attendance.end_time.nil?
            @attendance.update(end_time: DateTime.current.strftime('%H:%M'))
            flash[:notice] = '退勤打刻しました'        
            redirect_to jobs_home_path
        else
            flash[:alert] = '既に退勤打刻しています。'        
            redirect_to jobs_home_path        
        end
    end

    def manage
        @attendances = Attendance.where(group: current_user.group, attendance_date: Date.today)
        @schedules = Schedule.where(group: current_user.group, schedule_date: Date.today)

        #出席予定者数
        @user_count_att = @schedules.where(offday: false).count
        #欠席予定者数
        @user_count_holi = @schedules.where(offday: true).count

        #出勤者
        @attend_members = @attendances.where.not(start_time: nil)
        @attend_countA = @attend_members.count
        @attend_ratio = {}
        @attend_ratio.store("出勤済", @attend_countA)
        @attend_ratio.store("未出勤", @user_count_att - @attend_countA)

        #日報提出者
        @reports = Report.where(group: current_user.group, created_at: Date.today)
        @report_countA = @reports.count
        @report_ratio = {}
        @report_ratio.store("提出済", @report_countA)
        @report_ratio.store("未提出", @user_count_att - @report_countA)

        #退勤者
        @leave_members = @attendances.where.not(end_time: nil)
        @leave_countA = @leave_members.count
        @leave_ratio = {}
        @leave_ratio.store("退勤済", @leave_countA)
        @leave_ratio.store("未退勤", @user_count_att - @leave_countA)

        #退勤者数
        @leave = []
        @leave_members.each do |leave|
            user = User.find(leave.user_id)
            @leave << user.name
        end

        #日報提出者数
        @report = []
        @reports.each do |report|
            user = User.find(report.user_id)
            @report << user.name
        end

        #出勤者数
        @attend = []
        @attend_members.each do |attend|
            user = User.find(attend.user_id)
            @attend << user.name
        end

        #未出勤者数
        @fullusers = Schedule.where(group: current_user.group, schedule_date: Date.today, offday: false)
        @fulluser = []
        @fullusers.each do |fulluser|
            user = User.find(fulluser.user_id)
            @fulluser << user.name
        end
        
        @leave.size.times do |n|
            deleave = @leave["#{n}".to_i]
            @report.delete(deleave)
            @attend.delete(deleave)
            @fulluser.delete(deleave)
        end

        @report.size.times do |n|
            delreport = @report["#{n}".to_i]
            @attend.delete(delreport)
            @fulluser.delete(delreport)
        end

        @attend.size.times do |n|
            delatten = @attend["#{n}".to_i]
            @fulluser.delete(delatten)
        end
    end

    def data
        user = User.find(params[:q][:user_id])
        group = Group.find(user.group)
        data = @q.result.where(user_id: user.id)
        send_data PracticePdf::PostPdf.new(data,user,group).render, filename: "post_pdf.pdf", type: 'application/pdf',disposition: 'inline'

    end

    def post
        @user = User.find(current_user.id)
        @users = User.where(group: @user.group, admin:false)
    end  

    private
      def set_q
        @q = Report.ransack(params[:q])
      end
end
