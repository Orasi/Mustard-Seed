# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161005200640) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "environments", force: :cascade do |t|
    t.string   "uuid"
    t.integer  "project_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "environment_type"
    t.string   "display_name"
  end

  create_table "executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "project_id"
    t.boolean  "closed"
    t.datetime "closed_at"
    t.boolean  "deleted"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.boolean  "deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "api_key"
  end

  create_table "projects_teams", id: false, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id"
    t.integer  "project_id"
    t.index ["team_id", "project_id"], name: "index_projects_teams_on_team_id_and_project_id", unique: true, using: :btree
  end

  create_table "results", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "environment_id"
    t.integer  "testcase_id"
    t.integer  "execution_id"
    t.json     "results"
    t.string   "current_status"
  end

  create_table "screenshot_tokens", force: :cascade do |t|
    t.string   "token"
    t.datetime "expiration"
    t.integer  "screenshot_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "screenshots", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "screenshot_file_name"
    t.string   "screenshot_content_type"
    t.integer  "screenshot_file_size"
    t.datetime "screenshot_updated_at"
    t.date     "execution_start"
    t.string   "testcase_name"
    t.string   "environment_uuid"
    t.string   "project_name"
  end

  create_table "steps", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "testcase_id"
    t.integer  "step_number"
    t.text     "action"
    t.text     "expected"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.integer  "team_owner"
    t.text     "description"
  end

  create_table "teams_users", id: false, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id"
    t.integer  "user_id"
    t.index ["user_id", "team_id"], name: "index_teams_users_on_user_id_and_team_id", unique: true, using: :btree
  end

  create_table "testcases", force: :cascade do |t|
    t.string   "name"
    t.integer  "validation_id"
    t.integer  "project_id"
    t.datetime "runner_touch"
    t.boolean  "locked"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.json     "reproduction_steps"
  end

  create_table "user_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "expires"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "password_digest"
    t.boolean  "admin"
    t.boolean  "deleted"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
