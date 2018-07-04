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

ActiveRecord::Schema.define(version: 2018_07_04_102432) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "academic_years", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.integer "activity_type_id"
    t.string "title"
    t.text "description"
    t.date "happened_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "activity_category_id"
    t.index ["activity_category_id"], name: "index_activities_on_activity_category_id"
    t.index ["activity_type_id"], name: "index_activities_on_activity_type_id"
    t.index ["school_id"], name: "index_activities_on_school_id"
  end

  create_table "activity_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "badge_name"
  end

  create_table "activity_type_suggestions", id: :serial, force: :cascade do |t|
    t.integer "activity_type_id"
    t.integer "suggested_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type_id"], name: "index_activity_type_suggestions_on_activity_type_id"
    t.index ["suggested_type_id"], name: "index_activity_type_suggestions_on_suggested_type_id"
  end

  create_table "activity_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "activity_category_id"
    t.integer "score"
    t.string "badge_name"
    t.boolean "repeatable", default: true
    t.boolean "data_driven", default: false
    t.boolean "custom", default: false
    t.index ["active"], name: "index_activity_types_on_active"
    t.index ["activity_category_id"], name: "index_activity_types_on_activity_category_id"
  end

  create_table "aggregated_meter_readings", force: :cascade do |t|
    t.bigint "meter_id"
    t.decimal "readings", array: true
    t.date "when", null: false
    t.text "unit"
    t.decimal "total", default: "0.0"
    t.boolean "verified", default: false
    t.boolean "substitute", default: false
    t.index ["meter_id"], name: "index_aggregated_meter_readings_on_meter_id"
  end

  create_table "alert_types", force: :cascade do |t|
    t.integer "category"
    t.integer "sub_category"
    t.integer "frequency"
    t.text "title"
    t.text "description"
    t.text "analysis"
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "alert_type_id"
    t.bigint "school_id"
    t.index ["alert_type_id"], name: "index_alerts_on_alert_type_id"
    t.index ["school_id"], name: "index_alerts_on_school_id"
  end

  create_table "alerts_contacts", id: false, force: :cascade do |t|
    t.bigint "contact_id"
    t.bigint "alert_id"
    t.index ["alert_id"], name: "index_alerts_contacts_on_alert_id"
    t.index ["contact_id"], name: "index_alerts_contacts_on_contact_id"
  end

  create_table "areas", force: :cascade do |t|
    t.text "type", null: false
    t.text "title"
    t.text "description"
    t.integer "parent_area_id"
    t.index ["parent_area_id"], name: "index_areas_on_parent_area_id"
  end

  create_table "badges_sashes", id: :serial, force: :cascade do |t|
    t.integer "badge_id"
    t.integer "sash_id"
    t.boolean "notified_user", default: false
    t.datetime "created_at"
    t.index ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id"
    t.index ["badge_id"], name: "index_badges_sashes_on_badge_id"
    t.index ["sash_id"], name: "index_badges_sashes_on_sash_id"
  end

  create_table "bank_holidays", force: :cascade do |t|
    t.integer "calendar_area_id"
    t.date "holiday_date"
    t.text "title"
    t.text "notes"
    t.index ["calendar_area_id"], name: "index_bank_holidays_on_calendar_area_id"
  end

  create_table "calendar_event_types", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.text "alias"
    t.text "colour"
    t.boolean "term_time", default: false
    t.boolean "holiday", default: false
    t.boolean "school_occupied", default: false
    t.boolean "bank_holiday", default: false
    t.boolean "inset_day", default: false
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "academic_year_id"
    t.bigint "calendar_id"
    t.bigint "calendar_event_type_id"
    t.text "title"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.index ["academic_year_id"], name: "index_calendar_events_on_academic_year_id"
    t.index ["calendar_event_type_id"], name: "index_calendar_events_on_calendar_event_type_id"
    t.index ["calendar_id"], name: "index_calendar_events_on_calendar_id"
  end

  create_table "calendars", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.boolean "deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default"
    t.integer "based_on_id"
    t.integer "calendar_area_id"
    t.boolean "template", default: false
    t.index ["based_on_id"], name: "index_calendars_on_based_on_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "school_id"
    t.text "name"
    t.text "description"
    t.text "email_address"
    t.text "mobile_phone_number"
    t.index ["school_id"], name: "index_contacts_on_school_id"
  end

  create_table "data_feed_readings", force: :cascade do |t|
    t.bigint "data_feed_id"
    t.integer "feed_type"
    t.datetime "at"
    t.decimal "value"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "date_trunc('day'::text, at)", name: "data_feed_readings_at_index"
    t.index ["at"], name: "index_data_feed_readings_on_at"
    t.index ["data_feed_id"], name: "index_data_feed_readings_on_data_feed_id"
    t.index ["feed_type"], name: "index_data_feed_readings_on_feed_type"
  end

  create_table "data_feeds", force: :cascade do |t|
    t.text "type", null: false
    t.integer "area_id"
    t.text "title"
    t.text "description"
    t.json "configuration", default: {}, null: false
    t.index ["area_id"], name: "index_data_feeds_on_area_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "merit_actions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "action_method"
    t.integer "action_value"
    t.boolean "had_errors", default: false
    t.string "target_model"
    t.integer "target_id"
    t.text "target_data"
    t.boolean "processed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_merit_actions_on_user_id"
  end

  create_table "merit_activity_logs", id: :serial, force: :cascade do |t|
    t.integer "action_id"
    t.string "related_change_type"
    t.integer "related_change_id"
    t.string "description"
    t.datetime "created_at"
    t.index ["related_change_id", "related_change_type"], name: "merit_activity_logs_for_related_changes"
  end

  create_table "merit_score_points", id: :serial, force: :cascade do |t|
    t.integer "score_id"
    t.integer "num_points", default: 0
    t.string "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", id: :serial, force: :cascade do |t|
    t.integer "sash_id"
    t.string "category", default: "default"
    t.index ["sash_id"], name: "index_merit_scores_on_sash_id"
  end

  create_table "meter_readings", id: :serial, force: :cascade do |t|
    t.integer "meter_id"
    t.datetime "read_at"
    t.decimal "value"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id"], name: "index_meter_readings_on_meter_id"
    t.index ["read_at"], name: "index_meter_readings_on_read_at"
  end

  create_table "meters", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.integer "meter_type"
    t.bigint "meter_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "name"
    t.bigint "mpan_mprn"
    t.text "meter_serial_number"
    t.boolean "solar_pv", default: false
    t.boolean "storage_heaters", default: false
    t.integer "number_of_pupils"
    t.decimal "floor_area"
    t.index ["meter_no"], name: "index_meters_on_meter_no"
    t.index ["meter_type"], name: "index_meters_on_meter_type"
    t.index ["school_id"], name: "index_meters_on_school_id"
  end

  create_table "sashes", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "school_times", force: :cascade do |t|
    t.bigint "school_id"
    t.integer "opening_time", default: 850
    t.integer "closing_time", default: 1520
    t.integer "day"
    t.index ["school_id"], name: "index_school_times_on_school_id"
  end

  create_table "schools", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "school_type"
    t.text "address"
    t.string "postcode"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enrolled", default: false
    t.integer "urn", null: false
    t.integer "sash_id"
    t.integer "level", default: 0
    t.integer "calendar_id"
    t.string "slug"
    t.string "gas_dataset"
    t.string "electricity_dataset"
    t.integer "competition_role"
    t.integer "calendar_area_id"
    t.integer "temperature_area_id"
    t.integer "solar_irradiance_area_id"
    t.integer "met_office_area_id"
    t.integer "number_of_pupils"
    t.decimal "floor_area"
    t.integer "weather_underground_area_id"
    t.integer "solar_pv_tuos_area_id"
    t.index ["calendar_id"], name: "index_schools_on_calendar_id"
    t.index ["sash_id"], name: "index_schools_on_sash_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "terms", id: :serial, force: :cascade do |t|
    t.integer "calendar_id"
    t.string "academic_year"
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_terms_on_calendar_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  add_foreign_key "activities", "activity_categories"
  add_foreign_key "activities", "activity_types"
  add_foreign_key "activities", "schools"
  add_foreign_key "activity_type_suggestions", "activity_types"
  add_foreign_key "activity_types", "activity_categories"
  add_foreign_key "aggregated_meter_readings", "meters"
  add_foreign_key "alerts", "alert_types"
  add_foreign_key "alerts", "schools"
  add_foreign_key "calendar_events", "academic_years"
  add_foreign_key "calendar_events", "calendar_event_types"
  add_foreign_key "calendar_events", "calendars"
  add_foreign_key "contacts", "schools"
  add_foreign_key "data_feed_readings", "data_feeds"
  add_foreign_key "meter_readings", "meters"
  add_foreign_key "meters", "schools"
  add_foreign_key "school_times", "schools"
  add_foreign_key "schools", "calendars"
  add_foreign_key "terms", "calendars"
  add_foreign_key "users", "schools"
end
