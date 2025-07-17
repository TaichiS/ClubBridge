# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_17_110153) do
  create_table "club_selections", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "club_id", null: false
    t.integer "school_id", null: false
    t.integer "preference", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_club_selections_on_club_id"
    t.index ["school_id"], name: "index_club_selections_on_school_id"
    t.index ["student_id", "club_id"], name: "index_club_selections_on_student_id_and_club_id", unique: true
    t.index ["student_id", "preference"], name: "index_club_selections_on_student_id_and_preference", unique: true
    t.index ["student_id"], name: "index_club_selections_on_student_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "category"
    t.string "club_number"
    t.string "name"
    t.string "teacher_name"
    t.text "description"
    t.integer "max_members"
    t.string "location"
    t.string "rainy_day_location"
    t.text "note"
    t.integer "condition1"
    t.integer "condition2"
    t.integer "condition3"
    t.string "teacher_email"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_clubs_on_school_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.string "role"
    t.integer "user_id", null: false
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_memberships_on_school_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "school_settings", force: :cascade do |t|
    t.text "welcome_message"
    t.datetime "enrollment_start_time"
    t.datetime "enrollment_end_time"
    t.datetime "result_publication_start_time"
    t.datetime "result_publication_end_time"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_settings_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "school_type"
    t.text "address"
    t.string "website"
    t.text "description"
    t.string "contact_name"
    t.string "contact_title"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "student_count"
    t.string "club_count"
    t.date "expected_start_date"
    t.text "notes"
    t.string "applicant_name"
    t.string "applicant_email"
    t.text "rejection_reason"
    t.text "announcement"
    t.text "top_announcement"
    t.datetime "club_selection_start_time"
    t.datetime "club_selection_end_time"
    t.datetime "result_announcement_start_time"
    t.datetime "result_announcement_end_time"
    t.text "semester_schedule"
    t.integer "min_required_choices"
  end

  create_table "students", force: :cascade do |t|
    t.integer "grade"
    t.integer "class_number"
    t.string "class_name"
    t.integer "seat_number"
    t.string "student_id"
    t.string "name"
    t.string "id_card_number"
    t.integer "condition1"
    t.integer "condition2"
    t.integer "condition3"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "special", default: 0
    t.index ["school_id"], name: "index_students_on_school_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "api_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "user_role", default: 0, null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["user_role"], name: "index_users_on_user_role"
  end

  add_foreign_key "club_selections", "clubs"
  add_foreign_key "club_selections", "schools"
  add_foreign_key "club_selections", "students"
  add_foreign_key "clubs", "schools"
  add_foreign_key "memberships", "schools"
  add_foreign_key "memberships", "users"
  add_foreign_key "school_settings", "schools"
  add_foreign_key "students", "schools"
end
