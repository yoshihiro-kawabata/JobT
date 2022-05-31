class SchedulesController < ApplicationController
    before_action :login_required
    before_action :set_schedule, only: [:show]
    before_action :set_q, only: [:index, :search]
        
    def index
      @users = User.all
      users = User.all.count
      @schedules = []

      users.times do |n|
        @schedules << @q.result.where(user_id: "#{n}").where(schedule_date: (Date.today.beginning_of_month)..(Date.today.end_of_month)).order("schedule_date ASC")
      end

    end
      
    def show
        @user = User.find(@schedule.user_id)
    end
                  
    def search
        @users = User.all
        users = User.all.count
        @schedules = []
  
        users.times do |n|
          @schedules << @q.result.where(user_id: "#{n}").order("schedule_date ASC")
        end
  
    end
      
    private
      def set_schedule
        @schedule = Schedule.find(params[:id])
      end
      
      def set_q
        @q = Schedule.ransack(params[:q])
      end

end
