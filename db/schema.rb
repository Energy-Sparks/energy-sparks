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

ActiveRecord::Schema.define(version: 20161003103415) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "meter_readings", force: :cascade do |t|
    t.integer  "meter_id"
    t.datetime "read_at"
    t.decimal  "value"
    t.string   "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id"], name: "index_meter_readings_on_meter_id", using: :btree
    t.index ["read_at"], name: "index_meter_readings_on_read_at", using: :btree
  end

  create_table "meters", force: :cascade do |t|
    t.integer  "school_id"
    t.integer  "meter_type"
    t.integer  "meter_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_no"], name: "index_meters_on_meter_no", using: :btree
    t.index ["meter_type"], name: "index_meters_on_meter_type", using: :btree
    t.index ["school_id"], name: "index_meters_on_school_id", using: :btree
  end

  create_table "schools", force: :cascade do |t|
    t.string   "name"
    t.integer  "school_type"
    t.text     "address"
    t.string   "postcode"
    t.integer  "eco_school_status"
    t.string   "website"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_foreign_key "meter_readings", "meters"
  add_foreign_key "meters", "schools"
end
