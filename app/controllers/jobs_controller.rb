class JobsController < ApplicationController
    before_action :login_required
    before_action :admin_required, only: [:manage, :data, :post]
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

            @users = User.where(group: current_user.group).where.not(id: current_user.id)
            @users.each do |user|
                @message = Message.new
                @message.content = DateTime.current.strftime('%H時%M分') + "に出勤しました。"
                @message.create_name = current_user.name
                @message.create_id = current_user.id
                @message.user_name = user.name
                @message.user_id = user.id
                @message.save
            end
            redirect_to jobs_home_path

        else
            flash[:notice] = '既に出勤打刻しています。'
            redirect_to jobs_home_path        
        end
    end

    def leave
        @attendance = Attendance.find_by(user_id: current_user.id, attendance_date: Date.today)
        if @attendance.start_time.nil?
            flash[:notice] = 'まだ出勤していません。'        
            redirect_to jobs_home_path
        else
            if @attendance.end_time.nil?
                @attendance.update(end_time: DateTime.current.strftime('%H:%M'))
                flash[:notice] = '退勤打刻しました'        
                @users = User.where(group: current_user.group).where.not(id: current_user.id)
                @users.each do |user|
                    @message = Message.new
                    @message.content = DateTime.current.strftime('%H時%M分') + "に退勤しました。"
                    @message.create_name = current_user.name
                    @message.create_id = current_user.id
                    @message.user_name = user.name
                    @message.user_id = user.id
                    @message.save
                end
                redirect_to jobs_home_path
            else
                flash[:notice] = '既に退勤打刻しています。'        
                redirect_to jobs_home_path        
            end
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
        @reports = Report.where(group: current_user.group, createdate: Date.today.strftime("%m月%d日"))
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

        #日報未提出退勤打刻者
        @forgetuser = []

        #退勤者数
        @leave = []
        @leave_members.each do |leave|
            user = User.find(leave.user_id)
            unless user.admin?
                report = Report.find_by(createdate: Date.today.strftime("%m月%d日"), user_id:user.id)
                if report.nil?
                    @forgetuser << user.name
                else
                    @leave << user.name
                end
            else
                @leave << user.name
            end
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

        @forgetuser.size.times do |n|
            delforge = @forgetuser["#{n}".to_i]
            @attend.delete(delforge)
            @fulluser.delete(delforge)
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
        if params[:q][:created_at_gteq].present? and params[:q][:created_at_lteq].present?
            filenameA = user.name + "_" + params[:q][:created_at_gteq] + "～" + params[:q][:created_at_lteq] + ".pdf"
        elsif params[:q][:created_at_gteq].present?
            filenameA = user.name + "_" + params[:q][:created_at_gteq] + "～.pdf"
        elsif params[:q][:created_at_lteq].present?
            filenameA = user.name + "_～" + params[:q][:created_at_lteq] + ".pdf"
        else
            filenameA = user.name + ".pdf"
        end
        send_data PracticePdf::PostPdf.new(data,user,group).render, filename: filenameA, type: 'application/pdf',disposition: 'inline'

    end

    def post
        @user = User.find(current_user.id)
        @users = User.where(group: @user.group, admin:false).order("id ASC")
    end  

    private
      def set_q
        @q = Report.ransack(params[:q])
      end
end
