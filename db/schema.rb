# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150303004215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cases", force: :cascade do |t|
    t.string   "name"
    t.date     "date_of_birth"
    t.string   "email"
    t.string   "home_phone_number"
    t.string   "home_address"
    t.string   "home_zip_code"
    t.string   "home_city"
    t.string   "home_state"
    t.string   "primary_language"
    t.string   "sex"
    t.json     "additional_household_members"
    t.boolean  "contact_by_email"
    t.boolean  "contact_by_text_message"
    t.boolean  "contact_by_phone_call"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "interview_early_morning"
    t.boolean  "interview_mid_morning"
    t.boolean  "interview_afternoon"
    t.boolean  "interview_late_afternoon"
    t.boolean  "interview_monday"
    t.boolean  "interview_tuesday"
    t.boolean  "interview_wednesday"
    t.boolean  "interview_thursday"
    t.boolean  "interview_friday"
  end

end
