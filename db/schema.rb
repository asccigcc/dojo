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

ActiveRecord::Schema[8.1].define(version: 2026_11_12_040543) do
  create_table "exercises", force: :cascade do |t|
    t.string "slug", null: false
    t.string "kind", null: false
    t.string "language", default: "ruby", null: false
    t.string "category", null: false
    t.string "title", null: false
    t.integer "position", null: false
    t.integer "parts_count", default: 1, null: false
    t.text "description_md", default: "", null: false
    t.text "starter_code", default: "", null: false
    t.text "prelude_code", default: "", null: false
    t.text "test_code"
    t.text "solution_code", default: "", null: false
    t.text "expected_code"
    t.text "notes_md"
    t.string "code_path"
    t.string "test_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "position"], name: "index_exercises_on_kind_and_position"
    t.index ["slug"], name: "index_exercises_on_slug", unique: true
  end

  create_table "parts", force: :cascade do |t|
    t.integer "exercise_id", null: false
    t.integer "number", null: false
    t.text "description_md", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id", "number"], name: "index_parts_on_exercise_id_and_number", unique: true
  end

  create_table "progresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "exercise_id", null: false
    t.integer "unlocked_part", default: 1, null: false
    t.integer "interval_index"
    t.datetime "next_review_at"
    t.string "last_result"
    t.integer "passes_count", default: 0, null: false
    t.datetime "last_attempted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_progresses_on_exercise_id"
    t.index ["user_id", "exercise_id"], name: "index_progresses_on_user_id_and_exercise_id", unique: true
    t.index ["user_id", "next_review_at"], name: "index_progresses_on_user_id_and_next_review_at"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "exercise_id", null: false
    t.integer "part_number", default: 1, null: false
    t.text "code", default: "", null: false
    t.string "status", default: "pending", null: false
    t.text "output"
    t.json "failure_details", default: [], null: false
    t.integer "runs", default: 0, null: false
    t.integer "assertions", default: 0, null: false
    t.integer "failures_count", default: 0, null: false
    t.integer "errors_count", default: 0, null: false
    t.integer "skips", default: 0, null: false
    t.integer "duration_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_submissions_on_exercise_id"
    t.index ["user_id", "exercise_id", "created_at"], name: "index_submissions_on_user_id_and_exercise_id_and_created_at"
    t.index ["user_id", "status", "created_at"], name: "index_submissions_on_user_id_and_status_and_created_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower(name)", name: "index_users_on_lower_name", unique: true
  end

  add_foreign_key "parts", "exercises", on_delete: :cascade
  add_foreign_key "progresses", "exercises", on_delete: :cascade
  add_foreign_key "progresses", "users", on_delete: :cascade
  add_foreign_key "submissions", "exercises", on_delete: :cascade
  add_foreign_key "submissions", "users", on_delete: :cascade
end
