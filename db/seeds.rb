require 'securerandom'

#master_templete
Templete.create!(
    id: 0,
    name: "基本スケジュール_管理者",
    start_time: "08:00",
    end_time: "17:00"
     )

Templete.create!(
    id: 1,
    name: "基本スケジュール_一般",
    start_time: "09:00",
    end_time: "18:00"
     )
    
#test_templete
4.times do |n|
    Templete.create!(
      id: "#{n + 2}",
      name: "テストスケジュール#{n + 1}",
      start_time: "0#{n + 4}:30",
      end_time: "#{n + 13}:30"
        )
  end

#master_group
Group.create!(
    id: 0,
    name: "基本グループ"
     )
    
#test_group
2.times do |n|
  Group.create!(
      id: "#{n + 1}",
      name: "テストグループ#{n + 1}"
        )
  end

#master_user
User.create!(
    id: 0,
    name: "master",
    number: "9999",
    email: "master@master.com",
    password: "master",
    password_confirmation: "master",
    templete: Templete.find(0).id,
    group: Group.find(0).id,
    admin: true
     )
userA = User.find(0)
groupA = Group.find(0)
templeteA = Templete.find(0)
userA.groups << groupA
userA.templetes << templeteA

#test_user
groupA = Group.find(0)
templeteA = Templete.find(1)

10.times do |n|
  User.create!(
    id: "#{n + 1}",
    name: "テスト太郎#{n + 1}",
    number: "#{(n + 1) * 1111}",
    email: "test#{n + 1}@test.com",
    password: "#{(n + 1) * 111111}",
    password_confirmation: "#{(n + 1) * 111111}",
    templete: templeteA.id,
    group: groupA.id,
    admin: false
    )
  userA = User.find("#{n + 1}")
  userA.groups << groupA
  userA.templetes << templeteA
end
    
#test_user
groupA = Group.find(1)

3.times do |n|
  templeteA = Templete.find("#{n + 2}")

  User.create!(
    id: "#{n + 11}",
    name: "テスト太郎#{n + 11}",
    number: "#{(n + 11) * 1111}",
    email: "test#{n + 11}@test.com",
    password: "#{(n + 11) * 111111}",
    password_confirmation: "#{(n + 11) * 111111}",
    templete: templeteA.id,
    group: groupA.id,
    admin: false
    )
  userA = User.find("#{n + 11}")
  userA.groups << groupA
  userA.templetes << templeteA
end

templeteA = Templete.find(5)

User.create!(
      id: "14",
      name: "管理者花子1",
      number: "#{14 * 1111}",
      email: "test14@test.com",
      password: "#{14 * 111111}",
      password_confirmation: "#{14 * 111111}",
      templete: templeteA.id,
      group: groupA.id,
      admin: true
  )
userA = User.find(14)
userA.groups << groupA
userA.templetes << templeteA

#test_user
groupA = Group.find(2)
3.times do |n|
  templeteA = Templete.find("#{n + 2}")

  User.create!(
    id: "#{n + 15}",
    name: "テスト太郎#{n + 15}",
    number: "#{(n + 15) * 1111}",
    email: "test#{n + 15}@test.com",
    password: "#{(n + 15) * 111111}",
    password_confirmation: "#{(n + 15) * 111111}",
    templete: templeteA.id,
    group: groupA.id,
    admin: false
    )
  userA = User.find("#{n + 15}")
  userA.groups << groupA
  userA.templetes << templeteA
end

templeteA = Templete.find(5)

User.create!(
  id: "18",
  name: "管理者花子2",
  number: "#{18 * 1111}",
  email: "test18@test.com",
  password: "#{18 * 111111}",
  password_confirmation: "#{18 * 111111}",
  templete: templeteA.id,
  group: groupA.id,  
  admin: true
  )
  userA = User.find(18)
  userA.groups << groupA
  userA.templetes << templeteA

  connection = ActiveRecord::Base.connection();
  connection.execute("select setval('users_id_seq',(select max(id) from users))")

#attendance
#schedule
#vacation
#message

start_day = Date.today
start_day_ago = start_day.days_ago(1)
start_day_since = start_day.days_since(1)
zero_day = start_day.months_ago(1).beginning_of_month
end_day = start_day.years_since(2).months_ago(1).end_of_month

start_timeA = start_day.since(9.hours)
end_timeA = start_day.since(18.hours)

userB = User.find(0)

numbA = 0

19.times do |n|
  userA = User.find("#{n}")
  templetesUser = TempletesUser.find_by(user_id:userA.id)
  templeteA = Templete.find(templetesUser.templete_id)  

  (zero_day..start_day_ago).each { |date|
  if date.wday == 0 or date.wday == 6 or HolidayJp.holiday?(date)
      start_timeB = ""
      end_timeB = ""
      statusB = "休み"
      offday = true
      start_timeC = ""
      end_timeC = ""
  else
      start_timeB = templeteA.start_time
      end_timeB = templeteA.end_time
      statusB = "出勤"
      offday = false
      start_timeC = start_timeA.since("#{n + 1}".to_i.minutes).strftime("%H:%M")      
      end_timeC = end_timeA.since("#{n + 1}".to_i.minutes).strftime("%H:%M")      
  end
  
  Attendance.create!(
    attendance_date: date,
    start_time: start_timeC,
    end_time: end_timeC,
    user_id: userA.id,
    group: userA.group
    )


  Schedule.create!(
      schedule_date: date,
      start_time: start_timeB,
      end_time: end_timeB,
      status: statusB,
      user_id: userA.id,
      group: userA.group,
      offday: offday
  )
  }

  (start_day..end_day).each { |date|
  Attendance.create!(
    attendance_date: date,
    user_id: "#{n}",
    group: userA.group
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
      user_id: userA.id,
      group: userA.group,
      offday: offday
  )

  numbA = "#{n}".to_i
  @attendance = Attendance.find_by(attendance_date:start_day, user_id: userA.id)
  if numbA % 4 != 0
  @attendance.update(start_time: start_timeA.strftime("%H:%M"))
  end
  if numbA % 2 != 0 
    @attendance.update(start_time: start_timeA.strftime("%H:%M"), end_time: end_timeA.strftime("%H:%M"))
  end

  }


  Vacation.create!(
    paid_count: "#{n + 12}",
    trans_count: "#{20 - n}",
    user_id: userA.id
  )
  
  Message.create!(
      content: "テストメッセージ#{n + 1}です",
      create_name: userA.name,
      create_id: userA.id,
      user_name: userB.name,
      user_id: userB.id
  )
end

#report
  @users = User.where(admin: false)
  @users.each do |user|
  (zero_day..start_day_ago).each { |date|
    if date.wday.between?(1, 5)  and !(HolidayJp.holiday?(date))
      Report.create!(
        daytask: "テスト日報" +  ("#{date}").to_date.strftime("%m月%d日") +  "の事実です。",
        emotion: "テスト日報" +  ("#{date}").to_date.strftime("%m月%d日") +  "の感情です。",
        learn: "テスト日報" +  ("#{date}").to_date.strftime("%m月%d日") +  "の学習です。",
        transition: "テスト日報" +  ("#{date}").to_date.strftime("%m月%d日") +  "の変化です。",
        admincom: "テスト日報" +  ("#{date}").to_date.strftime("%m月%d日") +  "の管理者コメントです。",
        user_id: user.id,
        user_name: user.name,
        group: user.group,
        createdate: ("#{date}").to_date.strftime("%m月%d日"),
        created_at: ("#{date}").to_date,
        updated_at: ("#{date}").to_date
      )
    end
  }
  end

  19.times do |n|
    numbA = "#{n}".to_i
    userA = User.find("#{n}")
    if numbA % 3 != 0 and userA.admin == false
      Report.create!(
        daytask: "テスト日報" +  start_day.strftime("%m月%d日") +  "の事実です。",
        emotion: "テスト日報" +  start_day.strftime("%m月%d日") +  "の感情です。",
        learn: "テスト日報" +  start_day.strftime("%m月%d日") +  "の学習です。",
        transition: "テスト日報" +  start_day.strftime("%m月%d日") +  "の変化です。",
        admincom: "テスト日報" +  start_day.strftime("%m月%d日") +  "の管理者コメントです。",
        user_id: userA.id,
        user_name: userA.name,
        group: userA.group,
        createdate: start_day.strftime("%m月%d日"),
        created_at: start_day.to_date,
        updated_at: start_day.to_date
      )
    end
  end

#document
Document.create!(
  number: 1,
  name: "スケジュール変更申請"
  )

Document.create!(
    number: 2,
    name: "勤怠変更申請"
  )

Document.create!(
  number: 3,
  name: "有給休暇申請"
  )
  
Document.create!(
    number: 4,
    name: "振替休暇申請"
  )

Document.create!(
    number: 5,
    name: "休日出勤申請"
  )

#request
#documents_request

  userA = User.find(1)
  userB = User.find_by(group: userA.group, admin: true)
  documentA = Document.find(1)

  Request.create!(
    request_type: documentA.name,
    period: Date.today.since(1.days),
    start_time: Date.today.since(13.hour).strftime("%H:%M"),
    end_time: Date.today.since(18.hour).strftime("%H:%M"),
    status: "午後出勤",
    reason: "午前半休のため。",
    create_name: userA.name,
    create_id: userA.id,
    consent_flg: true,
    user_id: userB.id
    )
  
  requestA = Request.find(1)
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

  userA = User.find(2)
  userB = User.find_by(group: userA.group, admin: true)
  documentA = Document.find(2)

  Request.create!(
    request_type: documentA.name,
    period: Date.today.since(1.days),
    start_time: Date.today.since(9.hour).strftime("%H:%M"),
    end_time: Date.today.since(18.hour).strftime("%H:%M"),
    status: "",
    reason: "研修期間のため。",
    create_name: userA.name,
    create_id: userA.id,
    consent_flg: true,
    user_id: userB.id
    )
  
  requestA = Request.find(2)
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

  userA = User.find(3)
  userB = User.find_by(group: userA.group, admin: true)
  documentA = Document.find(3)

  Request.create!(
    request_type: documentA.name,
    period: Date.today.since(1.days),
    start_time: "",
    end_time: "",
    status: "",
    reason: "私事都合のため。",
    create_name: userA.name,
    create_id: userA.id,
    consent_flg: true,
    user_id: userB.id
    )
  
  requestA = Request.find(3)
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

  userA = User.find(4)
  userB = User.find_by(group: userA.group, admin: true)
  documentA = Document.find(4)

  Request.create!(
    request_type: documentA.name,
    period: Date.today.since(7.days),
    start_time: "",
    end_time: "",
    status: "",
    reason: "私事都合のため。",
    create_name: userA.name,
    create_id: userA.id,
    consent_flg: true,
    user_id: userB.id
    )
  
  requestA = Request.find(4)
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

  userA = User.find(5)
  userB = User.find_by(group: userA.group, admin: true)
  documentA = Document.find(5)

  Request.create!(
    request_type: documentA.name,
    period: Date.today.since(2.days),
    start_time: Date.today.since(9.hour).strftime("%H:%M"),
    end_time: Date.today.since(21.hour).strftime("%H:%M"),
    status: "",
    reason: "リリースのため。",
    create_name: userA.name,
    create_id: userA.id,
    consent_flg: true,
    user_id: userB.id
    )
  
  requestA = Request.find(5)
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

  