class AttendancesController < ApplicationController
    before_action :login_required

    def index
        @user = User.find(current_user.id)
        @attendances = Attendance.where(user_id: @user.id).where(attendance_date: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("attendance_date ASC")
        @vacation = Vacation.find_by(user_id: @user.id)
    end

    def show
        @users = User.all
        users = User.all.count
        @attendances = []

        users.times do |n|
            @attendances << Attendance.where(user_id: n).where(attendance_date: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("attendance_date ASC")
        end
    end
  
    def edit
    end
  
    def update
        if @user.update(user_params)
            redirect_to user_path(@user.id)
            flash[:notice] = 'アカウントを更新しました'
        else
            render :edit
        end
    end

end
