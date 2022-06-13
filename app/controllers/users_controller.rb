class UsersController < ApplicationController
    skip_before_action :login_required
    skip_before_action :admin_required,  only: [:show, :edit, :update]
    before_action :set_user,  only: [:show, :edit, :update]
    before_action :correct_user, only: [:show, :edit]
  
      def new
          @user = User.new
          @templetes = Templete.all 
          @groups = Group.all
      end
  
      def create
        @user = User.new(user_params)

        if @user.save

          templeteA = Templete.find(@user.templete)
          @user.templetes << templeteA
                  
          groupA = Group.find(@user.group)
          @user.groups << groupA        

          start_day = Date.today.months_ago(1).beginning_of_month
          end_day = Date.today.years_since(2).end_of_month

          holiboxs = HolidayJp.between(start_day, end_day)
          holicounts = holiboxs.count
          holidays = {}
          holicounts.times do |i|
            holidays[holiboxs[i].date.strftime('%Y%m%d')] = holiboxs[i].name
          end  

          Vacation.create!(paid_count: 12, trans_count: 0, user_id: @user.id)

          (start_day..end_day).each { |date|

          Attendance.create!(
            attendance_date: date,
            user_id:  @user.id,
            group: @user.group
          )

          if date.wday == 0 or date.wday == 6 or HolidayJp.holiday?(date)
            start_timeB = ""
            end_timeB = ""
            statusB = "休み"
            offday = true
          else
            start_timeB = templeteA.start_time
            end_timeB = templeteA.end_time
            statusB = "出勤"
            offday = false
          end
        
          Schedule.create!(
            schedule_date: date,
            start_time: start_timeB,
            end_time: end_timeB,
            status: statusB,
            user_id: @user.id,
            group: @user.group,
            offday: offday
        )
      }
          flash[:notice] = 'ユーザーを作成しました'
          redirect_to jobs_home_path

        else
          @templetes = Templete.all 
          @groups = Group.all
          render :new
        end
      end
    
      def show
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
    
    private
      def set_user
        @user = User.find_by(id: params[:id])
      end
  
      def user_params
        params.require(:user).permit(:name, :number, :email, :admin, :password, :password_confirmation, :templete, :group)
      end

      def correct_user
        if @user.present?
          redirect_to current_user, notice: '操作に問題があります' unless current_user?(@user)
        else
          redirect_to current_user, notice: '操作に問題があります'
        end
      end
  
end
