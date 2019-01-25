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

ActiveRecord::Schema.define(version: 2019_01_11_153734) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "academic_years", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "school_id"
    t.bigint "activity_type_id"
    t.string "title"
    t.text "description"
    t.date "happened_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "activity_category_id"
    t.index ["activity_category_id"], name: "index_activities_on_activity_category_id"
    t.index ["activity_type_id"], name: "index_activities_on_activity_type_id"
    t.index ["school_id"], name: "index_activities_on_school_id"
  end

  create_table "activity_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "badge_name"
  end

  create_table "activity_timings", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "activity_type_impacts", id: false, force: :cascade do |t|
    t.bigint "activity_type_id", null: false
    t.bigint "impact_id", null: false
    t.index ["activity_type_id"], name: "index_activity_type_impacts_on_activity_type_id"
    t.index ["impact_id"], name: "index_activity_type_impacts_on_impact_id"
  end

  create_table "activity_type_key_stages", id: false, force: :cascade do |t|
    t.bigint "activity_type_id", null: false
    t.bigint "key_stage_id", null: false
    t.index ["activity_type_id"], name: "index_activity_type_key_stages_on_activity_type_id"
    t.index ["key_stage_id"], name: "index_activity_type_key_stages_on_key_stage_id"
  end

  create_table "activity_type_subjects", id: false, force: :cascade do |t|
    t.bigint "activity_type_id", null: false
    t.bigint "subject_id", null: false
    t.index ["activity_type_id"], name: "index_activity_type_subjects_on_activity_type_id"
    t.index ["subject_id"], name: "index_activity_type_subjects_on_subject_id"
  end

  create_table "activity_type_suggestions", force: :cascade do |t|
    t.bigint "activity_type_id"
    t.bigint "suggested_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type_id"], name: "index_activity_type_suggestions_on_activity_type_id"
    t.index ["suggested_type_id"], name: "index_activity_type_suggestions_on_suggested_type_id"
  end

  create_table "activity_type_timings", id: false, force: :cascade do |t|
    t.bigint "activity_type_id", null: false
    t.bigint "activity_timing_id", null: false
    t.index ["activity_timing_id"], name: "index_activity_type_timings_on_activity_timing_id"
    t.index ["activity_type_id"], name: "index_activity_type_timings_on_activity_type_id"
  end

  create_table "activity_type_topics", id: false, force: :cascade do |t|
    t.bigint "activity_type_id", null: false
    t.bigint "topic_id", null: false
    t.index ["activity_type_id"], name: "index_activity_type_topics_on_activity_type_id"
    t.index ["topic_id"], name: "index_activity_type_topics_on_topic_id"
  end

  create_table "activity_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "activity_category_id"
    t.integer "score"
    t.string "badge_name"
    t.boolean "repeatable", default: true
    t.boolean "data_driven", default: false
    t.boolean "custom", default: false
    t.index ["active"], name: "index_activity_types_on_active"
    t.index ["activity_category_id"], name: "index_activity_types_on_activity_category_id"
  end

  create_table "alert_subscriptions", force: :cascade do |t|
    t.bigint "alert_type_id"
    t.bigint "school_id"
    t.index ["alert_type_id"], name: "index_alert_subscriptions_on_alert_type_id"
    t.index ["school_id"], name: "index_alert_subscriptions_on_school_id"
  end

  create_table "alert_subscriptions_contacts", id: false, force: :cascade do |t|
    t.bigint "contact_id"
    t.bigint "alert_subscription_id"
    t.index ["alert_subscription_id"], name: "index_alert_subscriptions_contacts_on_alert_subscription_id"
    t.index ["contact_id"], name: "index_alert_subscriptions_contacts_on_contact_id"
  end

  create_table "alert_types", force: :cascade do |t|
    t.integer "fuel_type"
    t.integer "sub_category"
    t.integer "frequency"
    t.text "title"
    t.text "description"
    t.text "analysis"
    t.text "class_name"
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "school_id"
    t.bigint "alert_type_id"
    t.date "run_on"
    t.integer "status"
    t.text "summary"
    t.json "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_type_id"], name: "index_alerts_on_alert_type_id"
    t.index ["school_id"], name: "index_alerts_on_school_id"
  end

  create_table "amr_data_feed_configs", force: :cascade do |t|
    t.bigint "area_id"
    t.text "description", null: false
    t.text "s3_folder", null: false
    t.text "s3_archive_folder", null: false
    t.text "local_bucket_path", null: false
    t.text "access_type", null: false
    t.text "date_format", null: false
    t.text "mpan_mprn_field", null: false
    t.text "reading_date_field", null: false
    t.text "reading_fields", null: false, array: true
    t.text "column_separator", default: ",", null: false
    t.text "msn_field"
    t.text "provider_id_field"
    t.text "total_field"
    t.text "meter_description_field"
    t.text "postcode_field"
    t.text "units_field"
    t.text "header_example"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "handle_off_by_one", default: false
    t.index ["area_id"], name: "index_amr_data_feed_configs_on_area_id"
  end

  create_table "amr_data_feed_import_logs", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id"
    t.text "file_name"
    t.datetime "import_time"
    t.integer "records_imported"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amr_data_feed_config_id"], name: "index_amr_data_feed_import_logs_on_amr_data_feed_config_id"
  end

  create_table "amr_data_feed_readings", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id"
    t.bigint "meter_id"
    t.bigint "amr_data_feed_import_log_id"
    t.text "mpan_mprn", null: false
    t.text "reading_date", null: false
    t.text "readings", null: false, array: true
    t.text "total"
    t.text "postcode"
    t.text "school"
    t.text "description"
    t.text "units"
    t.text "meter_serial_number"
    t.text "provider_record_id"
    t.text "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amr_data_feed_config_id"], name: "index_amr_data_feed_readings_on_amr_data_feed_config_id"
    t.index ["amr_data_feed_import_log_id"], name: "index_amr_data_feed_readings_on_amr_data_feed_import_log_id"
    t.index ["meter_id"], name: "index_amr_data_feed_readings_on_meter_id"
    t.index ["mpan_mprn", "reading_date"], name: "unique_meter_readings", unique: true
    t.index ["mpan_mprn"], name: "index_amr_data_feed_readings_on_mpan_mprn"
  end

  create_table "amr_validated_readings", force: :cascade do |t|
    t.bigint "meter_id", null: false
    t.decimal "kwh_data_x48", null: false, array: true
    t.decimal "one_day_kwh", null: false
    t.date "reading_date", null: false
    t.text "status", null: false
    t.date "substitute_date"
    t.datetime "upload_datetime"
    t.index ["meter_id", "reading_date"], name: "unique_amr_meter_validated_readings", unique: true
    t.index ["meter_id"], name: "index_amr_validated_readings_on_meter_id"
  end

  create_table "areas", force: :cascade do |t|
    t.text "type", null: false
    t.text "title"
    t.text "description"
    t.bigint "parent_area_id"
    t.index ["parent_area_id"], name: "index_areas_on_parent_area_id"
  end

  create_table "badges_sashes", force: :cascade do |t|
    t.bigint "badge_id"
    t.bigint "sash_id"
    t.boolean "notified_user", default: false
    t.datetime "created_at"
    t.index ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id"
    t.index ["badge_id"], name: "index_badges_sashes_on_badge_id"
    t.index ["sash_id"], name: "index_badges_sashes_on_sash_id"
  end

  create_table "bank_holidays", force: :cascade do |t|
    t.bigint "calendar_area_id"
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
    t.bigint "calendar_id", null: false
    t.bigint "calendar_event_type_id"
    t.text "title"
    t.text "description"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.index ["academic_year_id"], name: "index_calendar_events_on_academic_year_id"
    t.index ["calendar_event_type_id"], name: "index_calendar_events_on_calendar_event_type_id"
    t.index ["calendar_id"], name: "index_calendar_events_on_calendar_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default"
    t.bigint "based_on_id"
    t.bigint "calendar_area_id"
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
    t.bigint "area_id"
    t.text "title"
    t.text "description"
    t.json "configuration", default: {}, null: false
    t.index ["area_id"], name: "index_data_feeds_on_area_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "impacts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "key_stages", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_key_stages_on_name", unique: true
  end

  create_table "merit_actions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action_method"
    t.integer "action_value"
    t.boolean "had_errors", default: false
    t.string "target_model"
    t.bigint "target_id"
    t.text "target_data"
    t.boolean "processed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_merit_actions_on_user_id"
  end

  create_table "merit_activity_logs", force: :cascade do |t|
    t.bigint "action_id"
    t.string "related_change_type"
    t.bigint "related_change_id"
    t.string "description"
    t.datetime "created_at"
    t.index ["related_change_id", "related_change_type"], name: "merit_activity_logs_for_related_changes"
  end

  create_table "merit_score_points", force: :cascade do |t|
    t.bigint "score_id"
    t.integer "num_points", default: 0
    t.string "log"
    t.datetime "created_at"
    t.index ["score_id"], name: "index_merit_score_points_on_score_id"
  end

  create_table "merit_scores", force: :cascade do |t|
    t.bigint "sash_id"
    t.string "category", default: "default"
    t.index ["sash_id"], name: "index_merit_scores_on_sash_id"
  end

  create_table "meters", force: :cascade do |t|
    t.bigint "school_id"
    t.integer "meter_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "name"
    t.bigint "mpan_mprn"
    t.text "meter_serial_number"
    t.index ["meter_type"], name: "index_meters_on_meter_type"
    t.index ["mpan_mprn"], name: "index_meters_on_mpan_mprn", unique: true
    t.index ["school_id"], name: "index_meters_on_school_id"
  end

  create_table "sashes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.bigint "scoreboard_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_calendar_area_id"
    t.bigint "default_solar_pv_tuos_area_id"
    t.bigint "default_weather_underground_area_id"
    t.index ["default_calendar_area_id"], name: "index_school_groups_on_default_calendar_area_id"
    t.index ["default_solar_pv_tuos_area_id"], name: "index_school_groups_on_default_solar_pv_tuos_area_id"
    t.index ["default_weather_underground_area_id"], name: "index_school_groups_on_default_weather_underground_area_id"
    t.index ["scoreboard_id"], name: "index_school_groups_on_scoreboard_id"
  end

  create_table "school_key_stages", id: false, force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "key_stage_id", null: false
    t.index ["key_stage_id"], name: "index_school_key_stages_on_key_stage_id"
    t.index ["school_id"], name: "index_school_key_stages_on_school_id"
  end

  create_table "school_onboarding_events", force: :cascade do |t|
    t.bigint "school_onboarding_id", null: false
    t.integer "event", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_onboarding_id"], name: "index_school_onboarding_events_on_school_onboarding_id"
  end

  create_table "school_onboardings", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "school_name", null: false
    t.string "contact_email", null: false
    t.text "notes"
    t.bigint "school_id"
    t.bigint "created_user_id"
    t.bigint "created_by_id"
    t.bigint "school_group_id"
    t.bigint "weather_underground_area_id"
    t.bigint "solar_pv_tuos_area_id"
    t.bigint "calendar_area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_area_id"], name: "index_school_onboardings_on_calendar_area_id"
    t.index ["created_by_id"], name: "index_school_onboardings_on_created_by_id"
    t.index ["created_user_id"], name: "index_school_onboardings_on_created_user_id"
    t.index ["school_group_id"], name: "index_school_onboardings_on_school_group_id"
    t.index ["school_id"], name: "index_school_onboardings_on_school_id"
    t.index ["solar_pv_tuos_area_id"], name: "index_school_onboardings_on_solar_pv_tuos_area_id"
    t.index ["uuid"], name: "index_school_onboardings_on_uuid", unique: true
    t.index ["weather_underground_area_id"], name: "index_school_onboardings_on_weather_underground_area_id"
  end

  create_table "school_times", force: :cascade do |t|
    t.bigint "school_id"
    t.integer "opening_time", default: 850
    t.integer "closing_time", default: 1520
    t.integer "day"
    t.index ["school_id"], name: "index_school_times_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.integer "school_type"
    t.text "address"
    t.string "postcode"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.integer "urn", null: false
    t.bigint "sash_id"
    t.integer "level", default: 0
    t.bigint "calendar_id"
    t.string "slug"
    t.bigint "calendar_area_id"
    t.bigint "temperature_area_id"
    t.bigint "solar_irradiance_area_id"
    t.bigint "met_office_area_id"
    t.integer "number_of_pupils"
    t.decimal "floor_area"
    t.bigint "weather_underground_area_id"
    t.bigint "solar_pv_tuos_area_id"
    t.bigint "school_group_id"
    t.index ["calendar_id"], name: "index_schools_on_calendar_id"
    t.index ["sash_id"], name: "index_schools_on_sash_id"
    t.index ["school_group_id"], name: "index_schools_on_school_group_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "scoreboards", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "simulations", force: :cascade do |t|
    t.text "title"
    t.text "notes"
    t.bigint "school_id"
    t.bigint "user_id"
    t.text "configuration"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_simulations_on_school_id"
    t.index ["user_id"], name: "index_simulations_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "terms", force: :cascade do |t|
    t.bigint "calendar_id"
    t.string "academic_year"
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_terms_on_calendar_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.bigint "school_id"
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
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  add_foreign_key "activities", "activity_categories"
  add_foreign_key "activities", "activity_types"
  add_foreign_key "activities", "schools"
  add_foreign_key "activity_type_impacts", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_impacts", "impacts", on_delete: :restrict
  add_foreign_key "activity_type_key_stages", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_key_stages", "key_stages", on_delete: :restrict
  add_foreign_key "activity_type_subjects", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_subjects", "subjects", on_delete: :restrict
  add_foreign_key "activity_type_suggestions", "activity_types"
  add_foreign_key "activity_type_timings", "activity_timings", on_delete: :restrict
  add_foreign_key "activity_type_timings", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_topics", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_topics", "topics", on_delete: :restrict
  add_foreign_key "activity_types", "activity_categories"
  add_foreign_key "alert_subscriptions", "alert_types"
  add_foreign_key "alert_subscriptions", "schools"
  add_foreign_key "amr_validated_readings", "meters"
  add_foreign_key "calendar_events", "academic_years"
  add_foreign_key "calendar_events", "calendar_event_types"
  add_foreign_key "calendar_events", "calendars"
  add_foreign_key "contacts", "schools"
  add_foreign_key "data_feed_readings", "data_feeds"
  add_foreign_key "meters", "schools"
  add_foreign_key "school_groups", "areas", column: "default_calendar_area_id"
  add_foreign_key "school_groups", "areas", column: "default_solar_pv_tuos_area_id"
  add_foreign_key "school_groups", "areas", column: "default_weather_underground_area_id"
  add_foreign_key "school_groups", "scoreboards"
  add_foreign_key "school_key_stages", "key_stages", on_delete: :restrict
  add_foreign_key "school_key_stages", "schools", on_delete: :cascade
  add_foreign_key "school_onboarding_events", "school_onboardings", on_delete: :cascade
  add_foreign_key "school_onboardings", "areas", column: "calendar_area_id", on_delete: :restrict
  add_foreign_key "school_onboardings", "areas", column: "solar_pv_tuos_area_id", on_delete: :restrict
  add_foreign_key "school_onboardings", "areas", column: "weather_underground_area_id", on_delete: :restrict
  add_foreign_key "school_onboardings", "school_groups", on_delete: :restrict
  add_foreign_key "school_onboardings", "schools", on_delete: :cascade
  add_foreign_key "school_onboardings", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "school_onboardings", "users", column: "created_user_id", on_delete: :nullify
  add_foreign_key "school_times", "schools"
  add_foreign_key "schools", "calendars"
  add_foreign_key "schools", "school_groups"
  add_foreign_key "simulations", "schools"
  add_foreign_key "simulations", "users"
  add_foreign_key "terms", "calendars"
  add_foreign_key "users", "schools"
end
