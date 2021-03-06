class RequestsController < ApplicationController
    before_action :set_request, only: [:show, :destroy]
    skip_before_action :admin_required

        
  def index
      @requests = Request.where(create_id: current_user.id, consent_flg: true).page params[:page]
  end
      
  def show
  end

  def new
      @request = Request.new
      @documents = Document.all
  end

  def create
      @request = Request.new(request_params)
      userA = User.find(current_user.id)
      @schedule = Schedule.find_by(schedule_date:@request.period, user_id: userA.id)

      if @request.period.blank?
        @request.errors.messages.store(:period, ["を指定してください"])
        back_page
      elsif @schedule.nil?
        case @request.request_type
          when "2" then #勤怠変更申請
            @request.errors.messages.store(:attendance, ["が指定した日に存在しません"])
          else
            @request.errors.messages.store(:schedule, ["が指定した日に存在しません"])
        end
        back_page        
      else
      error_count = []
      error_message = []
      errorA = 0

      documentA = Document.find(@request.request_type)

     case @request.request_type
      when "1" then #スケジュール変更申請
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が指定した日に存在しません"]
        end
        if @request.start_time == ""
          error_count << "s"
          error_message << ["を入力してください"]
        end
        if @request.end_time == ""
          error_count << "e"
          error_message << ["を入力してください"]
        end
        if @request.status == ""
          error_count << "st"
          error_message << ["を入力してください"]
        end

        if (@request.start_time.present? and @request.end_time.present?) and @request.start_time == @request.end_time
          error_count << "s"
          error_message << ["が終了時間と同じです"]
        end
        if @schedule.offday?
          error_count << "hol"
          error_message << ["は休みです"]
        end    

      when "2" then #勤怠変更申請
        @attendance = Attendance.find_by(attendance_date:@request.period, user_id: userA.id)
        if @attendance.nil?
          error_count << "att"
          error_message << ["が指定した日に存在しません"]
        end
        if @request.start_time == ""
          error_count << "s"
          error_message << ["を入力してください"]
        end
        if @request.end_time == ""
          error_count << "e"
          error_message << ["を入力してください"]
        end
        if (@request.start_time.present? and @request.end_time.present?) and @request.start_time == @request.end_time
          error_count << "s"
          error_message << ["が終了時間と同じです"]
        end

        start_timeA = "" + @request.period.to_s + " " + @request.start_time.to_s
        end_timeA = "" + @request.period.to_s + " " + @request.end_time.to_s

        if (@request.period > Date.today) or (start_timeA.to_time > Time.current or end_timeA.to_time > Time.current)
          error_count << "fut"
          error_message << ["の勤怠申請はできません"]
        end

        if @schedule.offday?
          error_count << "hol"
          error_message << ["は休みです"]
        end    

        @request.status = ""

      when "3" then #有給休暇申請
        @vacation = Vacation.find_by(user_id: userA.id)
        yukyu = Request.where(request_type: "有給休暇申請", create_id: userA.id, consent_flg: true).count
        paid_countA = @vacation.paid_count - (yukyu + 1)
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が指定した日に存在しません"]
        end
        if paid_countA < 0
          error_count << "pc"
          error_message << ["が足りていません"]
        end
        if @schedule.offday?
          error_count << "hol"
          error_message << ["は休みです"]
        end    

        @request.start_time = ""
        @request.end_time = ""
        @request.status = ""

      when "4" then #振替休日申請
        @vacation = Vacation.find_by(user_id: userA.id)
        hurikae = Request.where(request_type: "振替休日申請", create_id: userA.id, consent_flg: true).count
        trans_countA = @vacation.trans_count - (hurikae + 1)
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が指定した日に存在しません"]
        end
        if trans_countA < 0
          error_count << "tc"
          error_message << ["が足りていません"]
        end
        if @schedule.offday?
          error_count << "hol"
          error_message << ["は休みです"]
        end    

        @request.start_time = ""
        @request.end_time = ""
        @request.status = ""

      when "5" then #休日出勤スケジュール変更申請
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が指定した日に存在しません"]
        end
        if @request.start_time == ""
          error_count << "s"
          error_message << ["を入力してください"]
        end
        if @request.end_time == ""
          error_count << "e"
          error_message << ["を入力してください"]
        end
        if (@request.start_time.present? and @request.end_time.present?) and @request.start_time == @request.end_time
          error_count << "s"
          error_message << ["が終了時間と同じです"]
        end
        if @request.status == ""
          error_count << "st"
          error_message << ["を入力してください"]
        end

        unless @schedule.offday?
          error_count << "hol"
          error_message << ["は出勤予定です"]
        end    
      end

      requestO = Request.find_by(period:@request.period, create_id: userA.id, consent_flg: true)

      if requestO.present?
        error_count << "exi"
        error_message << ["は既に別の申請を提出しています"]
      end

      @request.request_type = documentA.name
      @request.create_name = userA.name
      @request.create_id = userA.id
      @request.consent_flg = true
      @request.user_id = userA.id

      if error_count.size > 0
        @request.errors.messages.store(@request.request_type, ["は申請できませんでした"])
        error_count.size.times do |n|
          case error_count[n]
          when "sch" then #スケジュール
            @request.errors.messages.store(:schedule, error_message[n])
          when "att" then #勤怠表
            @request.errors.messages.store(:attendance, error_message[n])
          when "s" then #開始時間
            @request.errors.messages.store(:start_time, error_message[n])
          when "e" then #終了時間
            @request.errors.messages.store(:end_time, error_message[n])
          when "pc" then #有給休暇
            @request.errors.messages.store(:paid_count, error_message[n])
          when "tc" then #振替休日
            @request.errors.messages.store(:trans_count, error_message[n])
          when "hol" then #休日判定
            @request.errors.messages.store(@request.period.strftime("%m月%d日"), error_message[n])
          when "fut" then #未来打刻判定
            @request.errors.messages.store(:future, error_message[n])
          when "exi" then #申請重複判定
            @request.errors.messages.store(@request.period.strftime("%m月%d日"), error_message[n])
          else          #ステータス
            @request.errors.messages.store(:status, error_message[n])
          end
        end
        errorA = 1
      else
        if @request.save
          requestA = Request.find(@request.id)
          requestA.documents << documentA

         case documentA.number
          when 1 then #スケジュール変更申請
            contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日：' + requestA.period.strftime("%m月%d日") + '\n修正後時刻：'  + requestA.start_time  + '～' + requestA.end_time + '\n修正後ステータス：' + requestA.status + '\n理由：'+ requestA.reason
          when 2 then #勤怠変更申請
            contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日：' + requestA.period.strftime("%m月%d日") + '\n修正後時刻：'  + requestA.start_time  + '～' + requestA.end_time + '\n理由：'+ requestA.reason
          when 3 then #有給休暇申請
            contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日：' + requestA.period.strftime("%m月%d日") + '\n理由：'+ requestA.reason
          when 4 then #振替休日申請
            contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日：' + requestA.period.strftime("%m月%d日") + '\n理由：'+ requestA.reason
          when 5 then #休日出勤スケジュール変更申請
            contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日：' + requestA.period.strftime("%m月%d日") + '\n修正後時刻：'  + requestA.start_time  + '～' + requestA.end_time + '\n理由：'+ requestA.reason
         end

         Consent.create!(
            request_content: contentA,
                request_flg: true,
                group: userA.group,
                user_id: userA.id,
                request_id: requestA.id
          )
        else
          errorA = 1
        end
      end

      if errorA == 1
        @request.request_type = documentA.number.to_s
        back_page
      else
        @users = User.where(group: userA.group, admin: true)
        @users.each do |user|
          @message = Message.new
          @message.content = '申請しました。\n申請種類：' + requestA.request_type + '\n作成日：' + requestA.created_at.strftime('%m月%d日%H時%M分')
          @message.create_name = current_user.name
          @message.create_id = current_user.id
          @message.user_name = user.name
          @message.user_id = user.id
          @message.save
        end
        redirect_to requests_path, notice: '申請しました。'
      end
    end    
  end

  def destroy
    @consent = Consent.find_by(request_id:@request.id)

    @users = User.where(group: current_user.group, admin: true)
    @users.each do |user|
      @message = Message.new
      @message.content = '申請を取り消しました。\n申請種類：' + @request.request_type + '\n作成日：' + @request.created_at.strftime('%m月%d日%H時%M分')
      @message.create_name = current_user.name
      @message.create_id = current_user.id
      @message.user_name = user.name
      @message.user_id = user.id
      @message.save
    end

    @request.destroy
    @consent.destroy
    redirect_to requests_path, notice: '申請は取り消されました'
  end
  
      
    private
      def set_request
        @request = Request.find(params[:id])
      end
      
      def request_params
        params.require(:request).permit(:request_type, :period, :start_time, :end_time, :status, :reason)
      end

      def back_page
        @documents = Document.all
        render :new  
      end

end
