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

ActiveRecord::Schema.define(version: 2019_10_24_143627) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "academic_years", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.integer "calendar_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "activity_type_id", null: false
    t.string "title"
    t.text "deprecated_description"
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
  end

  create_table "activity_timings", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "include_lower", default: false
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
    t.bigint "suggested_type_id", null: false
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
    t.text "deprecated_description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "activity_category_id", null: false
    t.integer "score"
    t.boolean "repeatable", default: true
    t.boolean "data_driven", default: false
    t.boolean "custom", default: false
    t.index ["active"], name: "index_activity_types_on_active"
    t.index ["activity_category_id"], name: "index_activity_types_on_activity_category_id"
  end

  create_table "alert_subscription_events", force: :cascade do |t|
    t.bigint "alert_id", null: false
    t.bigint "contact_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "communication_type", default: 0, null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "email_id"
    t.bigint "alert_type_rating_content_version_id", null: false
    t.bigint "find_out_more_id"
    t.bigint "content_generation_run_id", null: false
    t.string "unsubscription_uuid"
    t.decimal "priority", default: "0.0", null: false
    t.index ["alert_id"], name: "index_alert_subscription_events_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "alert_sub_content_v_id"
    t.index ["contact_id"], name: "index_alert_subscription_events_on_contact_id"
    t.index ["content_generation_run_id"], name: "index_alert_subscription_events_on_content_generation_run_id"
    t.index ["email_id"], name: "index_alert_subscription_events_on_email_id"
    t.index ["find_out_more_id"], name: "index_alert_subscription_events_on_find_out_more_id"
  end

  create_table "alert_type_rating_activity_types", force: :cascade do |t|
    t.bigint "activity_type_id", null: false
    t.integer "position", default: 0, null: false
    t.bigint "alert_type_rating_id", null: false
    t.index ["alert_type_rating_id"], name: "index_alert_type_rating_activity_types_on_alert_type_rating_id"
  end

  create_table "alert_type_rating_content_versions", force: :cascade do |t|
    t.bigint "alert_type_rating_id", null: false
    t.string "_teacher_dashboard_title"
    t.string "find_out_more_title"
    t.text "_find_out_more_content"
    t.integer "replaced_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "colour", default: 0, null: false
    t.string "_pupil_dashboard_title"
    t.string "sms_content"
    t.string "email_title"
    t.text "_email_content"
    t.text "find_out_more_chart_variable", default: "none"
    t.string "find_out_more_chart_title", default: ""
    t.date "find_out_more_start_date"
    t.date "find_out_more_end_date"
    t.date "teacher_dashboard_alert_start_date"
    t.date "teacher_dashboard_alert_end_date"
    t.date "pupil_dashboard_alert_start_date"
    t.date "pupil_dashboard_alert_end_date"
    t.date "sms_start_date"
    t.date "sms_end_date"
    t.date "email_start_date"
    t.date "email_end_date"
    t.date "public_dashboard_alert_start_date"
    t.date "public_dashboard_alert_end_date"
    t.string "_public_dashboard_title"
    t.date "management_dashboard_alert_start_date"
    t.date "management_dashboard_alert_end_date"
    t.string "_management_dashboard_title"
    t.string "_management_priorities_title"
    t.date "management_priorities_start_date"
    t.date "management_priorities_end_date"
    t.decimal "email_weighting", default: "5.0"
    t.decimal "sms_weighting", default: "5.0"
    t.decimal "management_dashboard_alert_weighting", default: "5.0"
    t.decimal "management_priorities_weighting", default: "5.0"
    t.decimal "pupil_dashboard_alert_weighting", default: "5.0"
    t.decimal "public_dashboard_alert_weighting", default: "5.0"
    t.decimal "teacher_dashboard_alert_weighting", default: "5.0"
    t.decimal "find_out_more_weighting", default: "5.0"
    t.string "analysis_title"
    t.string "analysis_subtitle"
    t.date "analysis_start_date"
    t.date "analysis_end_date"
    t.decimal "analysis_weighting", default: "5.0"
    t.index ["alert_type_rating_id"], name: "fom_content_v_fom_id"
  end

  create_table "alert_type_rating_unsubscriptions", force: :cascade do |t|
    t.bigint "alert_type_rating_id", null: false
    t.bigint "contact_id", null: false
    t.bigint "alert_subscription_event_id"
    t.integer "scope", null: false
    t.text "reason"
    t.integer "unsubscription_period", null: false
    t.date "effective_until"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_subscription_event_id"], name: "altunsub_event"
    t.index ["alert_type_rating_id"], name: "index_alert_type_rating_unsubscriptions_on_alert_type_rating_id"
    t.index ["contact_id"], name: "index_alert_type_rating_unsubscriptions_on_contact_id"
  end

  create_table "alert_type_ratings", force: :cascade do |t|
    t.bigint "alert_type_id", null: false
    t.decimal "rating_from", null: false
    t.decimal "rating_to", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sms_active", default: false
    t.boolean "email_active", default: false
    t.boolean "find_out_more_active", default: false
    t.boolean "teacher_dashboard_alert_active", default: false
    t.boolean "pupil_dashboard_alert_active", default: false
    t.boolean "public_dashboard_alert_active", default: false
    t.boolean "management_dashboard_alert_active", default: false
    t.boolean "management_priorities_active", default: false
    t.boolean "analysis_active", default: false
    t.index ["alert_type_id"], name: "index_alert_type_ratings_on_alert_type_id"
  end

  create_table "alert_types", force: :cascade do |t|
    t.integer "fuel_type"
    t.integer "sub_category"
    t.integer "frequency"
    t.text "title"
    t.text "class_name"
    t.integer "source", default: 0, null: false
    t.boolean "has_ratings", default: true
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "alert_type_id", null: false
    t.date "run_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "template_data", default: {}
    t.json "table_data", default: {}
    t.json "chart_data", default: {}
    t.decimal "rating"
    t.boolean "displayable", default: true, null: false
    t.boolean "analytics_valid", default: true, null: false
    t.integer "enough_data"
    t.integer "relevance", default: 0
    t.json "priority_data", default: {}
    t.index ["alert_type_id"], name: "index_alerts_on_alert_type_id"
    t.index ["school_id"], name: "index_alerts_on_school_id"
  end

  create_table "amr_data_feed_configs", force: :cascade do |t|
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
    t.boolean "row_per_reading", default: false, null: false
    t.integer "number_of_header_rows", default: 0, null: false
    t.integer "process_type", default: 0, null: false
  end

  create_table "amr_data_feed_import_logs", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id", null: false
    t.text "file_name"
    t.datetime "import_time"
    t.integer "records_imported"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amr_data_feed_config_id"], name: "index_amr_data_feed_import_logs_on_amr_data_feed_config_id"
  end

  create_table "amr_data_feed_readings", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id", null: false
    t.bigint "meter_id"
    t.bigint "amr_data_feed_import_log_id", null: false
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
    t.index ["reading_date"], name: "index_amr_validated_readings_on_reading_date"
  end

  create_table "analysis_pages", force: :cascade do |t|
    t.bigint "content_generation_run_id"
    t.bigint "alert_type_rating_content_version_id"
    t.bigint "alert_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "category"
    t.decimal "priority", default: "0.0"
    t.index ["alert_id"], name: "index_analysis_pages_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "index_analysis_pages_on_alert_type_rating_content_version_id"
    t.index ["content_generation_run_id"], name: "index_analysis_pages_on_content_generation_run_id"
  end

  create_table "areas", force: :cascade do |t|
    t.text "type", null: false
    t.text "title"
    t.text "description"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
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
    t.integer "analytics_event_type", default: 0, null: false
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "academic_year_id", null: false
    t.bigint "calendar_id", null: false
    t.bigint "calendar_event_type_id", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "based_on_id"
    t.integer "calendar_type"
    t.index ["based_on_id"], name: "index_calendars_on_based_on_id"
  end

  create_table "carbon_intensity_readings", force: :cascade do |t|
    t.date "reading_date", null: false
    t.decimal "carbon_intensity_x48", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reading_date"], name: "index_carbon_intensity_readings_on_reading_date", unique: true
  end

  create_table "configurations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.json "analysis_charts", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "gas_dashboard_chart_type", default: 0, null: false
    t.json "pupil_analysis_charts", default: {}, null: false
    t.json "fuel_configuration", default: {}
    t.integer "storage_heater_dashboard_chart_type", default: 0, null: false
    t.index ["school_id"], name: "index_configurations_on_school_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.text "name"
    t.text "description"
    t.text "email_address"
    t.text "mobile_phone_number"
    t.bigint "user_id"
    t.bigint "staff_role_id"
    t.index ["school_id"], name: "index_contacts_on_school_id"
    t.index ["staff_role_id"], name: "index_contacts_on_staff_role_id"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "content_generation_runs", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_content_generation_runs_on_school_id"
  end

  create_table "dark_sky_temperature_readings", force: :cascade do |t|
    t.bigint "area_id"
    t.date "reading_date", null: false
    t.decimal "temperature_celsius_x48", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id", "reading_date"], name: "index_dark_sky_temperature_readings_on_area_id_and_reading_date", unique: true
    t.index ["area_id"], name: "index_dark_sky_temperature_readings_on_area_id"
  end

  create_table "dashboard_alerts", force: :cascade do |t|
    t.integer "dashboard", null: false
    t.bigint "content_generation_run_id", null: false
    t.bigint "alert_id", null: false
    t.bigint "alert_type_rating_content_version_id", null: false
    t.bigint "find_out_more_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "priority", default: "0.0", null: false
    t.index ["alert_id"], name: "index_dashboard_alerts_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "index_dashboard_alerts_on_alert_type_rating_content_version_id"
    t.index ["content_generation_run_id"], name: "index_dashboard_alerts_on_content_generation_run_id"
    t.index ["find_out_more_id"], name: "index_dashboard_alerts_on_find_out_more_id"
  end

  create_table "emails", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_emails_on_contact_id"
  end

  create_table "equivalence_type_content_versions", force: :cascade do |t|
    t.text "_equivalence"
    t.bigint "equivalence_type_id", null: false
    t.bigint "replaced_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["equivalence_type_id"], name: "index_equivalence_type_content_versions_on_equivalence_type_id"
    t.index ["replaced_by_id"], name: "eqtcv_eqtcv_repl"
  end

  create_table "equivalence_types", force: :cascade do |t|
    t.integer "meter_type", null: false
    t.integer "time_period", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "image_name", default: 0, null: false
  end

  create_table "equivalences", force: :cascade do |t|
    t.bigint "equivalence_type_content_version_id", null: false
    t.bigint "school_id", null: false
    t.json "data", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "relevant", default: true
    t.index ["equivalence_type_content_version_id"], name: "index_equivalences_on_equivalence_type_content_version_id"
    t.index ["school_id"], name: "index_equivalences_on_school_id"
  end

  create_table "find_out_mores", force: :cascade do |t|
    t.bigint "alert_type_rating_content_version_id", null: false
    t.bigint "alert_id", null: false
    t.bigint "content_generation_run_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_find_out_mores_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "fom_fom_content_v_id"
    t.index ["content_generation_run_id"], name: "index_find_out_mores_on_content_generation_run_id"
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

  create_table "intervention_type_groups", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "icon", default: "question-circle"
  end

  create_table "intervention_types", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "intervention_type_group_id", null: false
    t.boolean "other", default: false
    t.integer "points"
    t.index ["intervention_type_group_id"], name: "index_intervention_types_on_intervention_type_group_id"
  end

  create_table "key_stages", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_key_stages_on_name", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_locations_on_school_id"
  end

  create_table "low_carbon_hub_installations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "amr_data_feed_config_id", null: false
    t.text "rbee_meter_id"
    t.json "information", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["amr_data_feed_config_id"], name: "index_low_carbon_hub_installations_on_amr_data_feed_config_id"
    t.index ["school_id"], name: "index_low_carbon_hub_installations_on_school_id"
  end

  create_table "management_priorities", force: :cascade do |t|
    t.bigint "content_generation_run_id", null: false
    t.bigint "alert_id", null: false
    t.bigint "find_out_more_id"
    t.bigint "alert_type_rating_content_version_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "priority", default: "0.0", null: false
    t.index ["alert_id"], name: "index_management_priorities_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "mp_altrcv"
    t.index ["content_generation_run_id"], name: "index_management_priorities_on_content_generation_run_id"
    t.index ["find_out_more_id"], name: "index_management_priorities_on_find_out_more_id"
  end

  create_table "meters", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.integer "meter_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "name"
    t.bigint "mpan_mprn"
    t.text "meter_serial_number"
    t.bigint "low_carbon_hub_installation_id"
    t.boolean "pseudo", default: false
    t.index ["low_carbon_hub_installation_id"], name: "index_meters_on_low_carbon_hub_installation_id"
    t.index ["meter_type"], name: "index_meters_on_meter_type"
    t.index ["mpan_mprn"], name: "index_meters_on_mpan_mprn", unique: true
    t.index ["school_id"], name: "index_meters_on_school_id"
  end

  create_table "observations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "at", null: false
    t.text "_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "observation_type", null: false
    t.bigint "intervention_type_id"
    t.bigint "activity_id"
    t.integer "points"
    t.boolean "visible", default: true
    t.index ["activity_id"], name: "index_observations_on_activity_id"
    t.index ["intervention_type_id"], name: "index_observations_on_intervention_type_id"
    t.index ["school_id"], name: "index_observations_on_school_id"
  end

  create_table "programme_activities", force: :cascade do |t|
    t.bigint "programme_id", null: false
    t.bigint "activity_type_id", null: false
    t.bigint "activity_id"
    t.integer "position", default: 0, null: false
    t.index ["activity_id"], name: "index_programme_activities_on_activity_id"
    t.index ["programme_id", "activity_type_id"], name: "programme_activity_type_uniq", unique: true
  end

  create_table "programme_type_activity_types", force: :cascade do |t|
    t.bigint "programme_type_id", null: false
    t.bigint "activity_type_id", null: false
    t.integer "position", default: 0, null: false
    t.index ["programme_type_id", "activity_type_id"], name: "programme_type_activity_type_uniq", unique: true
  end

  create_table "programme_types", force: :cascade do |t|
    t.text "title"
    t.boolean "active", default: false
    t.text "short_description"
    t.string "document_link"
  end

  create_table "programmes", force: :cascade do |t|
    t.bigint "programme_type_id", null: false
    t.bigint "school_id", null: false
    t.integer "status", default: 0, null: false
    t.date "started_on", null: false
    t.date "ended_on"
    t.text "title"
    t.string "document_link"
    t.index ["programme_type_id"], name: "index_programmes_on_programme_type_id"
    t.index ["school_id"], name: "index_programmes_on_school_id"
  end

  create_table "school_alert_type_exclusions", force: :cascade do |t|
    t.bigint "alert_type_id"
    t.bigint "school_id"
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_type_id"], name: "index_school_alert_type_exclusions_on_alert_type_id"
    t.index ["school_id"], name: "index_school_alert_type_exclusions_on_school_id"
  end

  create_table "school_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.bigint "scoreboard_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_solar_pv_tuos_area_id"
    t.bigint "default_weather_underground_area_id"
    t.bigint "default_dark_sky_area_id"
    t.bigint "default_template_calendar_id"
    t.index ["default_solar_pv_tuos_area_id"], name: "index_school_groups_on_default_solar_pv_tuos_area_id"
    t.index ["default_template_calendar_id"], name: "index_school_groups_on_default_template_calendar_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "dark_sky_area_id"
    t.bigint "template_calendar_id"
    t.index ["created_by_id"], name: "index_school_onboardings_on_created_by_id"
    t.index ["created_user_id"], name: "index_school_onboardings_on_created_user_id"
    t.index ["school_group_id"], name: "index_school_onboardings_on_school_group_id"
    t.index ["school_id"], name: "index_school_onboardings_on_school_id"
    t.index ["solar_pv_tuos_area_id"], name: "index_school_onboardings_on_solar_pv_tuos_area_id"
    t.index ["template_calendar_id"], name: "index_school_onboardings_on_template_calendar_id"
    t.index ["uuid"], name: "index_school_onboardings_on_uuid", unique: true
    t.index ["weather_underground_area_id"], name: "index_school_onboardings_on_weather_underground_area_id"
  end

  create_table "school_times", force: :cascade do |t|
    t.bigint "school_id", null: false
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
    t.integer "level", default: 0
    t.bigint "calendar_id"
    t.string "slug"
    t.bigint "temperature_area_id"
    t.bigint "solar_irradiance_area_id"
    t.bigint "met_office_area_id"
    t.integer "number_of_pupils"
    t.decimal "floor_area"
    t.bigint "weather_underground_area_id"
    t.bigint "solar_pv_tuos_area_id"
    t.bigint "school_group_id"
    t.bigint "dark_sky_area_id"
    t.boolean "has_solar_panels", default: false, null: false
    t.boolean "has_swimming_pool", default: false, null: false
    t.boolean "serves_dinners", default: false, null: false
    t.boolean "cooks_dinners_onsite", default: false, null: false
    t.boolean "cooks_dinners_for_other_schools", default: false, null: false
    t.integer "cooks_dinners_for_other_schools_count"
    t.integer "template_calendar_id"
    t.string "validation_cache_key", default: "initial"
    t.index ["calendar_id"], name: "index_schools_on_calendar_id"
    t.index ["school_group_id"], name: "index_schools_on_school_group_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "scoreboards", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "academic_year_calendar_id"
    t.index ["academic_year_calendar_id"], name: "index_scoreboards_on_academic_year_calendar_id"
  end

  create_table "simulations", force: :cascade do |t|
    t.text "title"
    t.text "notes"
    t.bigint "school_id", null: false
    t.bigint "user_id", null: false
    t.text "configuration"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_simulations_on_school_id"
    t.index ["user_id"], name: "index_simulations_on_user_id"
  end

  create_table "site_settings", force: :cascade do |t|
    t.boolean "message_for_no_contacts", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "management_priorities_dashboard_limit", default: 5
    t.integer "management_priorities_page_limit", default: 10
  end

  create_table "solar_pv_tuos_readings", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.text "gsp_name"
    t.integer "gsp_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.decimal "distance_km"
    t.date "reading_date", null: false
    t.decimal "generation_mw_x48", null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_id", "reading_date"], name: "index_solar_pv_tuos_readings_on_area_id_and_reading_date", unique: true
    t.index ["area_id"], name: "index_solar_pv_tuos_readings_on_area_id"
  end

  create_table "staff_roles", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "dashboard", default: 0, null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "temperature_recordings", force: :cascade do |t|
    t.bigint "observation_id", null: false
    t.bigint "location_id", null: false
    t.decimal "centigrade", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_temperature_recordings_on_location_id"
    t.index ["observation_id"], name: "index_temperature_recordings_on_observation_id"
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
    t.string "pupil_password"
    t.bigint "staff_role_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.bigint "school_group_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_group_id"], name: "index_users_on_school_group_id"
    t.index ["school_id", "pupil_password"], name: "index_users_on_school_id_and_pupil_password", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["staff_role_id"], name: "index_users_on_staff_role_id"
  end

  add_foreign_key "academic_years", "calendars", on_delete: :restrict
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
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
  add_foreign_key "alert_subscription_events", "alert_type_rating_content_versions", on_delete: :cascade
  add_foreign_key "alert_subscription_events", "alerts"
  add_foreign_key "alert_subscription_events", "contacts"
  add_foreign_key "alert_subscription_events", "content_generation_runs", on_delete: :cascade
  add_foreign_key "alert_subscription_events", "emails"
  add_foreign_key "alert_subscription_events", "find_out_mores", on_delete: :nullify
  add_foreign_key "alert_type_rating_activity_types", "alert_type_ratings", on_delete: :cascade
  add_foreign_key "alert_type_rating_content_versions", "alert_type_ratings", on_delete: :cascade
  add_foreign_key "alert_type_rating_unsubscriptions", "alert_subscription_events", on_delete: :cascade
  add_foreign_key "alert_type_rating_unsubscriptions", "alert_type_ratings", on_delete: :cascade
  add_foreign_key "alert_type_rating_unsubscriptions", "contacts", on_delete: :cascade
  add_foreign_key "alert_type_ratings", "alert_types", on_delete: :restrict
  add_foreign_key "amr_validated_readings", "meters"
  add_foreign_key "analysis_pages", "alert_type_rating_content_versions", on_delete: :restrict
  add_foreign_key "analysis_pages", "alerts", on_delete: :restrict
  add_foreign_key "analysis_pages", "content_generation_runs", on_delete: :cascade
  add_foreign_key "calendar_events", "academic_years"
  add_foreign_key "calendar_events", "calendar_event_types"
  add_foreign_key "calendar_events", "calendars"
  add_foreign_key "calendars", "calendars", column: "based_on_id", on_delete: :restrict
  add_foreign_key "configurations", "schools", on_delete: :cascade
  add_foreign_key "contacts", "schools"
  add_foreign_key "contacts", "staff_roles", on_delete: :restrict
  add_foreign_key "contacts", "users", on_delete: :cascade
  add_foreign_key "content_generation_runs", "schools", on_delete: :cascade
  add_foreign_key "dashboard_alerts", "alert_type_rating_content_versions", on_delete: :restrict
  add_foreign_key "dashboard_alerts", "alerts", on_delete: :cascade
  add_foreign_key "dashboard_alerts", "content_generation_runs", on_delete: :cascade
  add_foreign_key "dashboard_alerts", "find_out_mores", on_delete: :nullify
  add_foreign_key "emails", "contacts", on_delete: :cascade
  add_foreign_key "equivalence_type_content_versions", "equivalence_type_content_versions", column: "replaced_by_id", on_delete: :nullify
  add_foreign_key "equivalence_type_content_versions", "equivalence_types", on_delete: :cascade
  add_foreign_key "equivalences", "equivalence_type_content_versions", on_delete: :cascade
  add_foreign_key "equivalences", "schools", on_delete: :cascade
  add_foreign_key "find_out_mores", "alert_type_rating_content_versions", on_delete: :cascade
  add_foreign_key "find_out_mores", "alerts", on_delete: :cascade
  add_foreign_key "find_out_mores", "content_generation_runs", on_delete: :cascade
  add_foreign_key "intervention_types", "intervention_type_groups", on_delete: :cascade
  add_foreign_key "locations", "schools", on_delete: :cascade
  add_foreign_key "low_carbon_hub_installations", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "low_carbon_hub_installations", "schools", on_delete: :cascade
  add_foreign_key "management_priorities", "alert_type_rating_content_versions", on_delete: :restrict
  add_foreign_key "management_priorities", "alerts", on_delete: :cascade
  add_foreign_key "management_priorities", "content_generation_runs", on_delete: :cascade
  add_foreign_key "management_priorities", "find_out_mores", on_delete: :nullify
  add_foreign_key "meters", "low_carbon_hub_installations", on_delete: :cascade
  add_foreign_key "meters", "schools"
  add_foreign_key "observations", "activities", on_delete: :nullify
  add_foreign_key "observations", "intervention_types", on_delete: :restrict
  add_foreign_key "observations", "schools", on_delete: :cascade
  add_foreign_key "programmes", "programme_types", on_delete: :cascade
  add_foreign_key "programmes", "schools", on_delete: :cascade
  add_foreign_key "school_alert_type_exclusions", "alert_types", on_delete: :cascade
  add_foreign_key "school_alert_type_exclusions", "schools", on_delete: :cascade
  add_foreign_key "school_groups", "areas", column: "default_solar_pv_tuos_area_id"
  add_foreign_key "school_groups", "areas", column: "default_weather_underground_area_id"
  add_foreign_key "school_groups", "calendars", column: "default_template_calendar_id", on_delete: :nullify
  add_foreign_key "school_groups", "scoreboards"
  add_foreign_key "school_key_stages", "key_stages", on_delete: :restrict
  add_foreign_key "school_key_stages", "schools", on_delete: :cascade
  add_foreign_key "school_onboarding_events", "school_onboardings", on_delete: :cascade
  add_foreign_key "school_onboardings", "areas", column: "solar_pv_tuos_area_id", on_delete: :restrict
  add_foreign_key "school_onboardings", "areas", column: "weather_underground_area_id", on_delete: :restrict
  add_foreign_key "school_onboardings", "calendars", column: "template_calendar_id", on_delete: :nullify
  add_foreign_key "school_onboardings", "school_groups", on_delete: :restrict
  add_foreign_key "school_onboardings", "schools", on_delete: :cascade
  add_foreign_key "school_onboardings", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "school_onboardings", "users", column: "created_user_id", on_delete: :nullify
  add_foreign_key "school_times", "schools"
  add_foreign_key "schools", "calendars"
  add_foreign_key "schools", "school_groups"
  add_foreign_key "scoreboards", "calendars", column: "academic_year_calendar_id", on_delete: :nullify
  add_foreign_key "simulations", "schools"
  add_foreign_key "simulations", "users"
  add_foreign_key "solar_pv_tuos_readings", "areas", on_delete: :cascade
  add_foreign_key "temperature_recordings", "locations", on_delete: :cascade
  add_foreign_key "temperature_recordings", "observations", on_delete: :cascade
  add_foreign_key "users", "school_groups", on_delete: :restrict
  add_foreign_key "users", "schools"
  add_foreign_key "users", "staff_roles", on_delete: :restrict
end
