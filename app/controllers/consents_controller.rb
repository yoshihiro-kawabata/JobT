class ConsentsController < ApplicationController
    before_action :login_required
    before_action :admin_required
    before_action :set_consent, only: [:show,:update, :destroy]
        
    def index
        @consents = Consent.where(group: current_user.group, request_flg: true, request_flg: true)
    end

    def done
      @consents = Consent.where(group: current_user.group, request_flg: true, request_flg: false)
    end
      
    def show
    end

    def update
      @request = Request.find_by(id:@consent.request_id)
      documentA = Document.find_by(name:@request.request_type)
      @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)


      back_flg = 0
      noticeA = ""

      if @schedule.offday?
        case documentA.number
          when 1 then #スケジュール変更申請
            back_flg += 1
            noticeA = "勤怠予定が欠席となっています。「スケジュール」から勤怠予定を変更して、再度承認してください。　"
          when 2 then #勤怠変更申請
            back_flg += 1
            noticeA = "勤怠予定が欠席となっています。「スケジュール」から勤怠予定を変更して、再度承認してください。　"  
          when 3 then #有給休暇申請
            back_flg += 1
            noticeA = "勤怠予定が欠席となっています。「スケジュール」から勤怠予定を変更して、再度承認してください。　"  
          when 4 then #振替休日申請
            back_flg += 1
            noticeA = "勤怠予定が欠席となっています。「スケジュール」から勤怠予定を変更して、再度承認してください。　"
        end
    else
        case documentA.number
          when 5 then #休日出勤スケジュール変更申請
            back_flg += 1
            noticeA = "勤怠予定が出席となっています。「スケジュール」から勤怠予定を変更して、再度承認してください。　"
        end
      end    

      if back_flg > 0
           redirect_to consents_path
           flash[:notice] = noticeA
      else
        if @consent.update(name: current_user.name,request_flg: false)

            case documentA.number
            when 1 then #スケジュール変更申請
              @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
              @schedule.update(start_time: @request.start_time,end_time: @request.end_time,status: @request.status, comment: @request.reason)

            when 2 then #勤怠変更申請
                @attendance = Attendance.find_by(attendance_date:@request.period, user_id: @request.create_id)
                @attendance.update(start_time: @request.start_time,end_time: @request.end_time, comment: @request.reason ,edit_flg: true)

            when 3 then #有給休暇申請
              @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
              @vacation = Vacation.find_by(user_id: @request.create_id)
              paid_countA = @vacation.paid_count - 1
              @schedule.update(start_time: "",end_time: "",status: "休み",offday: true)
              @vacation.update(paid_count: paid_countA)

            when 4 then #振替休日申請
                @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
                @vacation = Vacation.find_by(user_id: @request.create_id)
                trans_countA = @vacation.trans_count - 1
                @schedule.update(start_time: "",end_time: "",status: "休み",offday: true)
                @vacation.update(trans_count: trans_countA)

            when 5 then #休日出勤スケジュール変更申請
                @schedule = Schedule.find_by(schedule_date:@request.period, user_id: @request.create_id)
                @vacation = Vacation.find_by(user_id: @request.create_id)
                trans_countA = @vacation.trans_count + 1
                @schedule.update(start_time: @request.start_time,end_time: @request.end_time,status: "出勤",offday: false)
                @vacation.update(trans_count: trans_countA)
           end
          
           @request.update(consent_flg: false)

           @user = User.find(@request.create_id)
           @message = Message.new
           @message.content = '申請は承認されました。申請種類：' + @request.request_type + '\n作成日：' + @request.created_at.strftime('%m月%d日%H時%M分')
           @message.create_name = current_user.name
           @message.create_id = current_user.id
           @message.user_name = @user.name
           @message.user_id = @user.id
           @message.save

           redirect_to consents_path, notice: '申請を承認しました'
        else
           redirect_to consents_path, notice: '承認できませんでした'
        end      
      end
    end

    def destroy
        @request = Request.find_by(id:@consent.request_id)
        @user = User.find(@request.create_id)

        if @consent.request_flg?
          @message = Message.new
          @message.content = '申請は取り消されました。申請種類：' + @request.request_type + '\n作成日：' + @request.created_at.strftime('%m月%d日%H時%M分')
          @message.create_name = current_user.name
          @message.create_id = current_user.id
          @message.user_name = @user.name
          @message.user_id = @user.id
          @message.save
          @request.destroy    
          @consent.destroy
          redirect_to consents_path, notice: '申請は取り消されました'
        else
          @request.destroy    
          @consent.destroy
          redirect_to done_consents_path, notice: '承認済み申請を削除しました'
        end
    end

    private
      def set_consent
        @consent = Consent.find(params[:id])
      end

end
