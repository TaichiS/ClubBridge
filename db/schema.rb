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

ActiveRecord::Schema[8.0].define(version: 2025_07_08_103543) do
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
    t.string "condition3"
    t.string "teacher_email"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_clubs_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "condition3"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_students_on_school_id"
  end

  add_foreign_key "clubs", "schools"
  add_foreign_key "students", "schools"
end
