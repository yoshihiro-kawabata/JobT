# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_05_26_012558) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.date "attendance_date", null: false
    t.text "start_time"
    t.text "end_time"
    t.bigint "user_id", null: false
    t.integer "group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "consents", force: :cascade do |t|
    t.text "request_content"
    t.boolean "request_flg"
    t.bigint "user_id", null: false
    t.bigint "request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_consents_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "documents_requests", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_id"], name: "index_documents_requests_on_document_id"
    t.index ["request_id"], name: "index_documents_requests_on_request_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "groups_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.text "create_name"
    t.bigint "create_id"
    t.text "user_name"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.text "daytask"
    t.text "emotion"
    t.text "learn"
    t.text "transition"
    t.text "admincom"
    t.bigint "user_id", null: false
    t.text "user_name"
    t.integer "group"
    t.text "createdate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.text "request_type", null: false
    t.date "period", null: false
    t.text "start_time"
    t.text "end_time"
    t.text "status"
    t.text "reason", null: false
    t.text "create_name"
    t.bigint "create_id", null: false
    t.boolean "consent_flg"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.date "schedule_date", null: false
    t.text "start_time"
    t.text "end_time"
    t.text "status"
    t.bigint "user_id", null: false
    t.integer "group"
    t.boolean "offday", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "templetes", force: :cascade do |t|
    t.string "name", null: false
    t.text "start_time"
    t.text "end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "templetes_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "templete_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["templete_id"], name: "index_templetes_users_on_templete_id"
    t.index ["user_id"], name: "index_templetes_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "number", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.integer "templete"
    t.integer "group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "vacations", force: :cascade do |t|
    t.integer "paid_count"
    t.integer "trans_count"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_vacations_on_user_id"
  end

  add_foreign_key "attendances", "users"
  add_foreign_key "consents", "users"
  add_foreign_key "documents_requests", "documents"
  add_foreign_key "documents_requests", "requests"
  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "requests", "users"
  add_foreign_key "schedules", "users"
  add_foreign_key "templetes_users", "templetes"
  add_foreign_key "templetes_users", "users"
  add_foreign_key "vacations", "users"
end
