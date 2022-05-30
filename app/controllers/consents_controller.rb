class ConsentsController < ApplicationController
    before_action :set_consent, only: [:show,:update, :destroy]
        
    def index
        @consents = Consent.where(user_id: current_user.id, request_flg: true).page params[:page]
    end
      
    def show
    end

    def update
        if @consent.update(request_flg: false)
            @request = Request.find_by(id:@consent.request_id)
            documentA = Document.find_by(name:@request.request_type)

            case documentA.number
            when 1 then #スケジュール変更申請
              @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
              @schedule.update(start_time: @request.start_time,end_time: @request.end_time,status: @request.status)

            when 2 then #勤怠変更申請
                @attendance = Attendance.find_by(attendance_date:@request.period, user_id: @request.create_id)
                @attendance.update(start_time: @request.start_time,end_time: @request.end_time)

            when 3 then #有給休暇申請
              @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
              @vacation = Vacation.find_by(user_id: @request.create_id)
              paid_countA = @vacation.paid_count - 1
              @schedule.update(start_time: @request.start_time,end_time: @request.end_time,status: "休み",offday: true)
              @vacation.update(paid_count: paid_countA)

            when 4 then #振替休日申請
                @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
                @vacation = Vacation.find_by(user_id: @request.create_id)
                trans_countA = @vacation.trans_count - 1
                @schedule.update(start_time: @request.start_time,end_time: @request.end_time,status: "休み",offday: true)
                @vacation.update(trans_count: trans_countA)

            when 5 then #休日出勤申請
                @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
                @vacation = Vacation.find_by(user_id: @request.create_id)
                trans_countA = @vacation.trans_count + 1
                @schedule.update(start_time: @request.start_time,end_time: @request.end_time,status: "出勤",offday: false)
                @vacation.update(trans_count: trans_countA)
           end
          
           @request.update(consent_flg: false)

           redirect_to consents_path, notice: '申請は承認されました'
        else
           redirect_to consents_path, notice: '承認できませんでした'
        end      
    end

    def destroy
        @request = Request.find_by(id:@consent.request_id)

        @request.destroy    
        @consent.destroy
        redirect_to consents_path, notice: '申請は取り消されました'
    end

    private
      def set_consent
        @consent = Consent.find(params[:id])
      end

end
