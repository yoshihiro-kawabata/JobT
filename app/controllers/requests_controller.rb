class RequestsController < ApplicationController
    before_action :set_request, only: [:show, :destroy]
        
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
      error_count = []
      error_message = []

      userA = User.find(current_user.id)
      userB = User.find_by(group: userA.group, admin: true)
      documentA = Document.find(@request.request_type)

     case @request.request_type
      when "1" then #スケジュール変更申請
        @schedule = Schedule.find_by(schedule_date:@request.period, user_id: userA.id)
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が存在しません"]
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
      when "2" then #勤怠変更申請
        @attendance = Attendance.find_by(attendance_date:@request.period, user_id: userA.id)
        if @attendance.nil?
          error_count << "att"
          error_message << ["が存在しません"]
        end
        if @request.start_time == ""
          error_count << "s"
          error_message << ["を入力してください"]
        end
        if @request.end_time == ""
          error_count << "e"
          error_message << ["を入力してください"]
        end
      when "3" then #有給休暇申請
        @schedule = Schedule.find_by(schedule_date:@request.period, user_id: userA.id)
        @vacation = Vacation.find_by(user_id: userA.id)
        paid_countA = @vacation.paid_count - 1
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が存在しません"]
        end
        if paid_countA < 0
          error_count << "pc"
          error_message << ["が足りていません"]
        end
        if @request.period.wday == 0 or @request.period.wday == 6 or HolidayJp.holiday?(@request.period)
          error_count << "hol"
          error_message << ["は休みです。"]
        end    
      when "4" then #振替休日申請
        @schedule = Schedule.find_by(schedule_date:@request.period, user_id: userA.id)
        @vacation = Vacation.find_by(user_id: userA.id)
        trans_countA = @vacation.trans_count - 1
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が存在しません"]
        end
        if trans_countA < 0
          error_count << "tc"
          error_message << ["が足りていません"]
        end
        if @request.period.wday == 0 or @request.period.wday == 6 or HolidayJp.holiday?(@request.period)
          error_count << "hol"
          error_message << ["は休みです。"]
        end    
      when "5" then #休日出勤申請
        @schedule = Schedule.find_by(schedule_date:@request.period, user_id: userA.id)
        if @schedule.nil?
          error_count << "sch"
          error_message << ["が存在しません"]
        end
        if @request.start_time == ""
          error_count << "s"
          error_message << ["を入力してください"]
        end
        if @request.end_time == ""
          error_count << "e"
          error_message << ["を入力してください"]
        end
        if @request.period.wday.between?(1, 5) and !(HolidayJp.holiday?(@request.period))
          error_count << "hol"
          error_message << ["は平日です。"]
        end    
     end
    
      @request.request_type = documentA.name
      @request.create_name = userA.name
      @request.create_id = userA.id
      @request.consent_flg = true
      @request.user_id = userB.id

    if error_count.size > 0
      @request.errors.messages.store(@request.request_type, ["は申請できませんでした。"])
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
          else          #ステータス
            @request.errors.messages.store(:status, error_message[n])
          end
        end
        @documents = Document.all
        render :new
    else
      if @request.save
        requestA = Request.find(@request.id)
        requestA.documents << documentA

       case documentA.number
        when 1 then #スケジュール変更申請
          contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日時：' + requestA.period.strftime("%m月%d日") + '\n修正後時刻：'  + requestA.start_time  + '～' + requestA.end_time + '\n修正後ステータス：' + requestA.status + '\n理由：'+ requestA.reason
        when 2 then #勤怠変更申請
          contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日時：' + requestA.period.strftime("%m月%d日") + '\n修正後時刻：'  + requestA.start_time  + '～' + requestA.end_time + '\n理由：'+ requestA.reason
        when 3 then #有給休暇申請
          contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日時：' + requestA.period.strftime("%m月%d日") + '\n理由：'+ requestA.reason
        when 4 then #振替休日申請
          contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日時：' + requestA.period.strftime("%m月%d日") + '\n理由：'+ requestA.reason
        when 5 then #休日出勤申請
          contentA = requestA.request_type + '\n作成者：' + requestA.create_name + '\n修正日時：' + requestA.period.strftime("%m月%d日") + '\n修正後時刻：'  + requestA.start_time  + '～' + requestA.end_time + '\n理由：'+ requestA.reason
       end
  
        Consent.create!(
          request_content: contentA,
                request_flg: true,
          user_id: userB.id,
          request_id: requestA.id
        )

        redirect_to requests_path, notice: '申請しました。'
      else
        @documents = Document.all
        render :new
      end
    end
  end

  def destroy
    @consent = Consent.find_by(request_id:@request.id)
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

end