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

ActiveRecord::Schema.define(version: 2023_06_19_085613) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
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
    t.string "locale", default: "en", null: false
    t.index ["record_type", "record_id", "name", "locale"], name: "index_action_text_rich_texts_uniqueness", unique: true
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
    t.boolean "featured", default: false
    t.boolean "pupil", default: false
    t.boolean "live_data", default: false
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
    t.boolean "data_driven", default: false
    t.boolean "custom", default: false
    t.string "summary"
    t.index ["active"], name: "index_activity_types_on_active"
    t.index ["activity_category_id"], name: "index_activity_types_on_activity_category_id"
  end

  create_table "admin_meter_statuses", force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "advice_page_activity_types", force: :cascade do |t|
    t.bigint "advice_page_id"
    t.bigint "activity_type_id"
    t.integer "position"
    t.index ["activity_type_id"], name: "index_advice_page_activity_types_on_activity_type_id"
    t.index ["advice_page_id"], name: "index_advice_page_activity_types_on_advice_page_id"
  end

  create_table "advice_page_intervention_types", force: :cascade do |t|
    t.bigint "advice_page_id"
    t.bigint "intervention_type_id"
    t.integer "position"
    t.index ["advice_page_id"], name: "index_advice_page_intervention_types_on_advice_page_id"
    t.index ["intervention_type_id"], name: "index_advice_page_intervention_types_on_intervention_type_id"
  end

  create_table "advice_page_school_benchmarks", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "advice_page_id", null: false
    t.integer "benchmarked_as", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["advice_page_id"], name: "index_advice_page_school_benchmarks_on_advice_page_id"
    t.index ["school_id"], name: "index_advice_page_school_benchmarks_on_school_id"
  end

  create_table "advice_pages", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "restricted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "fuel_type"
    t.index ["key"], name: "index_advice_pages_on_key", unique: true
  end

  create_table "alert_errors", force: :cascade do |t|
    t.bigint "alert_generation_run_id", null: false
    t.bigint "alert_type_id", null: false
    t.date "asof_date", null: false
    t.text "information"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_generation_run_id"], name: "index_alert_errors_on_alert_generation_run_id"
    t.index ["alert_type_id"], name: "index_alert_errors_on_alert_type_id"
  end

  create_table "alert_generation_runs", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_alert_generation_runs_on_school_id"
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
    t.string "unsubscription_uuid"
    t.decimal "priority", default: "0.0", null: false
    t.bigint "subscription_generation_run_id", null: false
    t.index ["alert_id"], name: "index_alert_subscription_events_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "alert_sub_content_v_id"
    t.index ["contact_id"], name: "index_alert_subscription_events_on_contact_id"
    t.index ["email_id"], name: "index_alert_subscription_events_on_email_id"
    t.index ["find_out_more_id"], name: "index_alert_subscription_events_on_find_out_more_id"
    t.index ["subscription_generation_run_id"], name: "ase_sgr_index"
  end

  create_table "alert_type_rating_activity_types", force: :cascade do |t|
    t.bigint "activity_type_id", null: false
    t.integer "position", default: 0, null: false
    t.bigint "alert_type_rating_id", null: false
    t.index ["alert_type_rating_id"], name: "index_alert_type_rating_activity_types_on_alert_type_rating_id"
  end

  create_table "alert_type_rating_content_versions", force: :cascade do |t|
    t.bigint "alert_type_rating_id", null: false
    t.string "find_out_more_title"
    t.integer "replaced_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "colour", default: 0, null: false
    t.string "sms_content"
    t.string "email_title"
    t.text "find_out_more_chart_variable", default: "none"
    t.string "find_out_more_chart_title", default: ""
    t.date "find_out_more_start_date"
    t.date "find_out_more_end_date"
    t.date "pupil_dashboard_alert_start_date"
    t.date "pupil_dashboard_alert_end_date"
    t.date "sms_start_date"
    t.date "sms_end_date"
    t.date "email_start_date"
    t.date "email_end_date"
    t.date "management_dashboard_alert_start_date"
    t.date "management_dashboard_alert_end_date"
    t.date "management_priorities_start_date"
    t.date "management_priorities_end_date"
    t.decimal "email_weighting", default: "5.0"
    t.decimal "sms_weighting", default: "5.0"
    t.decimal "management_dashboard_alert_weighting", default: "5.0"
    t.decimal "management_priorities_weighting", default: "5.0"
    t.decimal "pupil_dashboard_alert_weighting", default: "5.0"
    t.decimal "find_out_more_weighting", default: "5.0"
    t.text "find_out_more_table_variable", default: "none"
    t.string "analysis_title"
    t.string "analysis_subtitle"
    t.date "analysis_start_date"
    t.date "analysis_end_date"
    t.decimal "analysis_weighting", default: "5.0"
    t.date "management_dashboard_table_start_date"
    t.date "management_dashboard_table_end_date"
    t.decimal "management_dashboard_table_weighting", default: "5.0"
    t.index ["alert_type_rating_id"], name: "fom_content_v_fom_id"
  end

  create_table "alert_type_rating_intervention_types", force: :cascade do |t|
    t.bigint "intervention_type_id", null: false
    t.bigint "alert_type_rating_id", null: false
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_type_rating_id"], name: "idx_alert_type_rating_intervention_types_on_alrt_type_id"
    t.index ["intervention_type_id"], name: "idx_alert_type_rating_intervention_types_on_int_type_id"
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
    t.boolean "pupil_dashboard_alert_active", default: false
    t.boolean "public_dashboard_alert_active", default: false
    t.boolean "management_dashboard_alert_active", default: false
    t.boolean "management_priorities_active", default: false
    t.boolean "analysis_active", default: false
    t.boolean "management_dashboard_table_active", default: false
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
    t.boolean "background", default: false
    t.boolean "benchmark", default: false
    t.boolean "user_restricted", default: false, null: false
    t.bigint "advice_page_id"
    t.integer "link_to", default: 0, null: false
    t.string "link_to_section"
    t.integer "group", default: 0, null: false
    t.boolean "enabled", default: true, null: false
    t.index ["advice_page_id"], name: "index_alert_types_on_advice_page_id"
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
    t.bigint "alert_generation_run_id"
    t.json "template_data_cy", default: {}
    t.index ["alert_generation_run_id"], name: "index_alerts_on_alert_generation_run_id"
    t.index ["alert_type_id", "created_at"], name: "index_alerts_on_alert_type_id_and_created_at"
    t.index ["alert_type_id"], name: "index_alerts_on_alert_type_id"
    t.index ["run_on"], name: "index_alerts_on_run_on"
    t.index ["school_id"], name: "index_alerts_on_school_id"
  end

  create_table "amr_data_feed_configs", force: :cascade do |t|
    t.text "description", null: false
    t.text "identifier", null: false
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
    t.integer "source_type", default: 0, null: false
    t.integer "import_warning_days", default: 10
    t.string "expected_units"
    t.integer "missing_readings_limit"
    t.boolean "lookup_by_serial_number", default: false
    t.jsonb "column_row_filters", default: {}
    t.boolean "positional_index", default: false, null: false
    t.string "period_field"
    t.index ["description"], name: "index_amr_data_feed_configs_on_description", unique: true
    t.index ["identifier"], name: "index_amr_data_feed_configs_on_identifier", unique: true
  end

  create_table "amr_data_feed_import_logs", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id", null: false
    t.text "file_name"
    t.datetime "import_time"
    t.integer "records_imported"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "records_updated", default: 0, null: false
    t.text "error_messages"
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
    t.index ["meter_id", "amr_data_feed_config_id"], name: "adfr_meter_id_config_id"
    t.index ["meter_id"], name: "index_amr_data_feed_readings_on_meter_id"
    t.index ["mpan_mprn", "reading_date"], name: "unique_meter_readings", unique: true
    t.index ["mpan_mprn"], name: "index_amr_data_feed_readings_on_mpan_mprn"
  end

  create_table "amr_reading_warnings", force: :cascade do |t|
    t.bigint "amr_data_feed_import_log_id", null: false
    t.integer "warning"
    t.text "warning_message"
    t.text "reading_date"
    t.text "mpan_mprn"
    t.text "readings", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "warning_types", array: true
    t.integer "school_id"
    t.string "fuel_type"
    t.index ["amr_data_feed_import_log_id"], name: "index_amr_reading_warnings_on_amr_data_feed_import_log_id"
  end

  create_table "amr_uploaded_readings", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id", null: false
    t.boolean "imported", default: false, null: false
    t.text "file_name", default: "f", null: false
    t.json "reading_data", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["amr_data_feed_config_id"], name: "index_amr_uploaded_readings_on_amr_data_feed_config_id"
  end

  create_table "amr_validated_readings", force: :cascade do |t|
    t.bigint "meter_id", null: false
    t.decimal "kwh_data_x48", null: false, array: true
    t.decimal "one_day_kwh", null: false
    t.date "reading_date", null: false
    t.text "status", null: false
    t.date "substitute_date"
    t.datetime "upload_datetime"
    t.index ["meter_id", "one_day_kwh"], name: "index_amr_validated_readings_on_meter_id_and_one_day_kwh"
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
    t.integer "back_fill_years", default: 4
    t.string "gsp_name"
    t.integer "gsp_id"
    t.boolean "active", default: true
  end

  create_table "audit_activity_types", force: :cascade do |t|
    t.bigint "audit_id", null: false
    t.bigint "activity_type_id", null: false
    t.integer "position", default: 0, null: false
    t.text "notes"
    t.index ["audit_id"], name: "index_audit_activity_types_on_audit_id"
  end

  create_table "audit_intervention_types", force: :cascade do |t|
    t.bigint "audit_id", null: false
    t.bigint "intervention_type_id", null: false
    t.integer "position", default: 0, null: false
    t.text "notes"
    t.index ["audit_id"], name: "index_audit_intervention_types_on_audit_id"
  end

  create_table "audits", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "title", null: false
    t.date "completed_on"
    t.boolean "published", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "involved_pupils", default: false, null: false
    t.index ["school_id"], name: "index_audits_on_school_id"
  end

  create_table "benchmark_result_errors", force: :cascade do |t|
    t.bigint "benchmark_result_school_generation_run_id", null: false
    t.bigint "alert_type_id", null: false
    t.date "asof_date"
    t.text "information"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_type_id"], name: "index_benchmark_result_errors_on_alert_type_id"
    t.index ["benchmark_result_school_generation_run_id"], name: "ben_rgr_errors_index"
  end

  create_table "benchmark_result_generation_runs", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "benchmark_result_school_generation_runs", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "benchmark_result_generation_run_id"
    t.integer "benchmark_result_error_count", default: 0
    t.integer "benchmark_result_count", default: 0
    t.index ["benchmark_result_generation_run_id"], name: "benchmark_result_school_generation_run_idx"
    t.index ["school_id"], name: "index_benchmark_result_school_generation_runs_on_school_id"
  end

  create_table "benchmark_results", force: :cascade do |t|
    t.bigint "alert_type_id", null: false
    t.date "asof", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "benchmark_result_school_generation_run_id", null: false
    t.json "results", default: {}
    t.json "results_cy", default: {}
    t.index ["alert_type_id"], name: "index_benchmark_results_on_alert_type_id"
    t.index ["benchmark_result_school_generation_run_id"], name: "ben_rgr_index"
  end

  create_table "cads", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "name", null: false
    t.string "device_identifier", null: false
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "test_mode", default: false
    t.float "max_power", default: 3.0
    t.integer "refresh_interval", default: 5
    t.bigint "meter_id"
    t.index ["meter_id"], name: "index_cads_on_meter_id"
    t.index ["school_id"], name: "index_cads_on_school_id"
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
    t.text "description"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.bigint "based_on_id"
    t.datetime "created_at", precision: 6, default: -> { "(CURRENT_TIMESTAMP - '1 mon'::interval)" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "(CURRENT_TIMESTAMP - '1 mon'::interval)" }, null: false
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

  create_table "case_studies", force: :cascade do |t|
    t.string "title"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cluster_schools_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "school_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_cluster_schools_users_on_school_id"
    t.index ["user_id", "school_id"], name: "index_cluster_schools_users_on_user_id_and_school_id"
    t.index ["user_id"], name: "index_cluster_schools_users_on_user_id"
  end

  create_table "configurations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.json "analysis_charts", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "pupil_analysis_charts", default: {}, null: false
    t.json "fuel_configuration", default: {}
    t.string "school_target_fuel_types", default: [], null: false, array: true
    t.string "suggest_estimates_fuel_types", default: [], null: false, array: true
    t.json "estimated_consumption", default: {}
    t.json "aggregate_meter_dates", default: {}
    t.string "dashboard_charts", default: [], null: false, array: true
    t.index ["school_id"], name: "index_configurations_on_school_id"
  end

  create_table "consent_documents", force: :cascade do |t|
    t.bigint "school_id"
    t.text "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_consent_documents_on_school_id"
  end

  create_table "consent_documents_meter_reviews", id: false, force: :cascade do |t|
    t.bigint "consent_document_id"
    t.bigint "meter_review_id"
    t.index ["consent_document_id"], name: "index_consent_documents_meter_reviews_on_consent_document_id"
    t.index ["meter_review_id"], name: "index_consent_documents_meter_reviews_on_meter_review_id"
  end

  create_table "consent_grants", force: :cascade do |t|
    t.bigint "consent_statement_id", null: false
    t.bigint "user_id"
    t.bigint "school_id", null: false
    t.text "name"
    t.text "job_title"
    t.text "school_name"
    t.text "ip_address"
    t.text "guid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consent_statement_id"], name: "index_consent_grants_on_consent_statement_id"
    t.index ["school_id"], name: "index_consent_grants_on_school_id"
    t.index ["user_id"], name: "index_consent_grants_on_user_id"
  end

  create_table "consent_statements", force: :cascade do |t|
    t.text "title", null: false
    t.boolean "current", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.bigint "area_id", null: false
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

  create_table "dashboard_messages", force: :cascade do |t|
    t.text "message"
    t.string "messageable_type"
    t.bigint "messageable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["messageable_type", "messageable_id"], name: "index_dashboard_messages_on_messageable_type_and_messageable_id", unique: true
  end

  create_table "data_sources", force: :cascade do |t|
    t.string "name", null: false
    t.integer "organisation_type"
    t.string "contact_name"
    t.string "contact_email"
    t.text "loa_contact_details"
    t.text "data_prerequisites"
    t.string "data_feed_type"
    t.text "new_area_data_feed"
    t.text "add_existing_data_feed"
    t.text "data_issues_contact_details"
    t.text "historic_data"
    t.text "loa_expiry_procedure"
    t.text "comments"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "import_warning_days"
  end

  create_table "emails", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_emails_on_contact_id"
  end

  create_table "equivalence_type_content_versions", force: :cascade do |t|
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
    t.date "from_date"
    t.date "to_date"
    t.json "data_cy", default: {}
    t.index ["equivalence_type_content_version_id"], name: "index_equivalences_on_equivalence_type_content_version_id"
    t.index ["school_id"], name: "index_equivalences_on_school_id"
  end

  create_table "estimated_annual_consumptions", force: :cascade do |t|
    t.integer "year", null: false
    t.float "electricity"
    t.float "storage_heaters"
    t.float "gas"
    t.bigint "school_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_estimated_annual_consumptions_on_school_id"
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

  create_table "global_meter_attributes", force: :cascade do |t|
    t.string "attribute_type", null: false
    t.json "input_data"
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "replaced_by_id"
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.jsonb "meter_types", default: []
    t.index ["created_by_id"], name: "index_global_meter_attributes_on_created_by_id"
    t.index ["deleted_by_id"], name: "index_global_meter_attributes_on_deleted_by_id"
    t.index ["replaced_by_id"], name: "index_global_meter_attributes_on_replaced_by_id"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "help_pages", force: :cascade do |t|
    t.string "title"
    t.integer "feature", null: false
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_help_pages_on_slug", unique: true
  end

  create_table "impacts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "intervention_type_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "icon", default: "question-circle"
    t.string "description"
    t.boolean "active", default: true
  end

  create_table "intervention_type_suggestions", force: :cascade do |t|
    t.bigint "intervention_type_id"
    t.integer "suggested_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["intervention_type_id"], name: "index_intervention_type_suggestions_on_intervention_type_id"
    t.index ["suggested_type_id"], name: "index_intervention_type_suggestions_on_suggested_type_id"
  end

  create_table "intervention_types", force: :cascade do |t|
    t.string "name"
    t.bigint "intervention_type_group_id", null: false
    t.boolean "custom", default: false
    t.integer "score"
    t.boolean "active", default: true
    t.string "summary"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["intervention_type_group_id"], name: "index_intervention_types_on_intervention_type_group_id"
  end

  create_table "issue_meters", force: :cascade do |t|
    t.bigint "issue_id"
    t.bigint "meter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_issue_meters_on_issue_id"
    t.index ["meter_id"], name: "index_issue_meters_on_meter_id"
  end

  create_table "issues", force: :cascade do |t|
    t.integer "issue_type", default: 0, null: false
    t.string "title", null: false
    t.integer "fuel_type"
    t.integer "status", default: 0, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "owned_by_id"
    t.boolean "pinned", default: false
    t.string "issueable_type"
    t.bigint "issueable_id"
    t.index ["created_by_id"], name: "index_issues_on_created_by_id"
    t.index ["issueable_type", "issueable_id"], name: "index_issues_on_issueable_type_and_issueable_id"
    t.index ["owned_by_id"], name: "index_issues_on_owned_by_id"
    t.index ["updated_by_id"], name: "index_issues_on_updated_by_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "voluntary", default: false
    t.date "closing_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "key_stages", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_key_stages_on_name", unique: true
  end

  create_table "link_rewrites", force: :cascade do |t|
    t.string "source"
    t.string "target"
    t.string "rewriteable_type"
    t.bigint "rewriteable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["rewriteable_type", "rewriteable_id"], name: "index_link_rewrites_on_rewriteable_type_and_rewriteable_id"
  end

  create_table "local_authority_areas", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.string "username"
    t.string "password"
    t.index ["amr_data_feed_config_id"], name: "index_low_carbon_hub_installations_on_amr_data_feed_config_id"
    t.index ["school_id"], name: "index_low_carbon_hub_installations_on_school_id"
  end

  create_table "management_dashboard_tables", force: :cascade do |t|
    t.bigint "content_generation_run_id"
    t.bigint "alert_id"
    t.bigint "alert_type_rating_content_version_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_id"], name: "index_management_dashboard_tables_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "man_dash_alert_content_version_index"
    t.index ["content_generation_run_id"], name: "index_management_dashboard_tables_on_content_generation_run_id"
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

  create_table "manual_data_load_run_log_entries", force: :cascade do |t|
    t.bigint "manual_data_load_run_id", null: false
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["manual_data_load_run_id"], name: "manual_data_load_run_log_idx"
  end

  create_table "manual_data_load_runs", force: :cascade do |t|
    t.bigint "amr_uploaded_reading_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["amr_uploaded_reading_id"], name: "index_manual_data_load_runs_on_amr_uploaded_reading_id"
  end

  create_table "meter_attributes", force: :cascade do |t|
    t.bigint "meter_id", null: false
    t.string "attribute_type", null: false
    t.json "input_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "reason"
    t.bigint "replaced_by_id"
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.index ["meter_id"], name: "index_meter_attributes_on_meter_id"
  end

  create_table "meter_reviews", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "user_id", null: false
    t.bigint "consent_grant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consent_grant_id"], name: "index_meter_reviews_on_consent_grant_id"
    t.index ["school_id"], name: "index_meter_reviews_on_school_id"
    t.index ["user_id"], name: "index_meter_reviews_on_user_id"
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
    t.bigint "solar_edge_installation_id"
    t.boolean "dcc_meter", default: false
    t.boolean "consent_granted", default: false
    t.date "earliest_available_data"
    t.boolean "sandbox", default: false
    t.bigint "meter_review_id"
    t.datetime "dcc_checked_at"
    t.bigint "data_source_id"
    t.bigint "admin_meter_statuses_id"
    t.bigint "procurement_route_id"
    t.index ["data_source_id"], name: "index_meters_on_data_source_id"
    t.index ["low_carbon_hub_installation_id"], name: "index_meters_on_low_carbon_hub_installation_id"
    t.index ["meter_review_id"], name: "index_meters_on_meter_review_id"
    t.index ["meter_type"], name: "index_meters_on_meter_type"
    t.index ["mpan_mprn"], name: "index_meters_on_mpan_mprn", unique: true
    t.index ["procurement_route_id"], name: "index_meters_on_procurement_route_id"
    t.index ["school_id"], name: "index_meters_on_school_id"
    t.index ["solar_edge_installation_id"], name: "index_meters_on_solar_edge_installation_id"
  end

  create_table "meters_user_tariffs", id: false, force: :cascade do |t|
    t.bigint "meter_id"
    t.bigint "user_tariff_id"
    t.index ["meter_id"], name: "index_meters_user_tariffs_on_meter_id"
    t.index ["user_tariff_id"], name: "index_meters_user_tariffs_on_user_tariff_id"
  end

  create_table "mobility_string_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.string "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_string_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_string_translations_on_keys", unique: true
    t.index ["translatable_type", "key", "value", "locale"], name: "index_mobility_string_translations_on_query_keys"
  end

  create_table "mobility_text_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.text "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "newsletters", force: :cascade do |t|
    t.text "title", null: false
    t.text "url", null: false
    t.date "published_on", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.bigint "audit_id"
    t.boolean "involved_pupils", default: false, null: false
    t.bigint "school_target_id"
    t.index ["activity_id"], name: "index_observations_on_activity_id"
    t.index ["audit_id"], name: "index_observations_on_audit_id"
    t.index ["intervention_type_id"], name: "index_observations_on_intervention_type_id"
    t.index ["school_id"], name: "index_observations_on_school_id"
    t.index ["school_target_id"], name: "index_observations_on_school_target_id"
  end

  create_table "partners", force: :cascade do |t|
    t.integer "position", default: 0, null: false
    t.text "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
  end

  create_table "procurement_routes", force: :cascade do |t|
    t.string "organisation_name", null: false
    t.string "contact_name"
    t.string "contact_email"
    t.string "loa_contact_details"
    t.text "data_prerequisites"
    t.text "new_area_data_feed"
    t.text "add_existing_data_feed"
    t.text "data_issues_contact_details"
    t.text "loa_expiry_procedure"
    t.text "comments"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "programme_activities", force: :cascade do |t|
    t.bigint "programme_id", null: false
    t.bigint "activity_type_id", null: false
    t.bigint "activity_id", null: false
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
    t.boolean "default", default: false
    t.datetime "created_at", precision: 6, default: "2022-07-06 12:00:00", null: false
    t.datetime "updated_at", precision: 6, default: "2022-07-06 12:00:00", null: false
  end

  create_table "programmes", force: :cascade do |t|
    t.bigint "programme_type_id", null: false
    t.bigint "school_id", null: false
    t.integer "status", default: 0, null: false
    t.date "started_on", null: false
    t.date "ended_on"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["programme_type_id"], name: "index_programmes_on_programme_type_id"
    t.index ["school_id"], name: "index_programmes_on_school_id"
  end

  create_table "resource_file_types", force: :cascade do |t|
    t.string "title", null: false
    t.integer "position", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "resource_files", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "resource_file_type_id"
    t.index ["resource_file_type_id"], name: "index_resource_files_on_resource_file_type_id"
  end

  create_table "rtone_variant_installations", force: :cascade do |t|
    t.string "username", null: false
    t.string "password", null: false
    t.string "rtone_meter_id", null: false
    t.integer "rtone_component_type", null: false
    t.json "configuration"
    t.bigint "school_id", null: false
    t.bigint "amr_data_feed_config_id", null: false
    t.bigint "meter_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["amr_data_feed_config_id"], name: "index_rtone_variant_installations_on_amr_data_feed_config_id"
    t.index ["meter_id"], name: "index_rtone_variant_installations_on_meter_id"
    t.index ["school_id"], name: "index_rtone_variant_installations_on_school_id"
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

  create_table "school_batch_run_log_entries", force: :cascade do |t|
    t.bigint "school_batch_run_id"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_batch_run_id"], name: "index_school_batch_run_log_entries_on_school_batch_run_id"
  end

  create_table "school_batch_runs", force: :cascade do |t|
    t.bigint "school_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_school_batch_runs_on_school_id"
  end

  create_table "school_group_meter_attributes", force: :cascade do |t|
    t.bigint "school_group_id", null: false
    t.string "attribute_type", null: false
    t.json "input_data"
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "replaced_by_id"
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.jsonb "meter_types", default: []
    t.index ["school_group_id"], name: "index_school_group_meter_attributes_on_school_group_id"
  end

  create_table "school_group_partners", force: :cascade do |t|
    t.bigint "school_group_id"
    t.bigint "partner_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id"], name: "index_school_group_partners_on_partner_id"
    t.index ["school_group_id"], name: "index_school_group_partners_on_school_group_id"
  end

  create_table "school_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.bigint "default_scoreboard_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_solar_pv_tuos_area_id"
    t.bigint "default_dark_sky_area_id"
    t.bigint "default_template_calendar_id"
    t.bigint "default_weather_station_id"
    t.boolean "public", default: true
    t.integer "default_chart_preference", default: 0, null: false
    t.bigint "default_issues_admin_user_id"
    t.integer "default_country", default: 0, null: false
    t.bigint "admin_meter_statuses_electricity_id"
    t.bigint "admin_meter_statuses_gas_id"
    t.bigint "admin_meter_statuses_solar_pv_id"
    t.bigint "default_data_source_electricity_id"
    t.bigint "default_data_source_gas_id"
    t.bigint "default_data_source_solar_pv_id"
    t.bigint "default_procurement_route_electricity_id"
    t.bigint "default_procurement_route_gas_id"
    t.bigint "default_procurement_route_solar_pv_id"
    t.integer "group_type", default: 0
    t.index ["default_issues_admin_user_id"], name: "index_school_groups_on_default_issues_admin_user_id"
    t.index ["default_scoreboard_id"], name: "index_school_groups_on_default_scoreboard_id"
    t.index ["default_solar_pv_tuos_area_id"], name: "index_school_groups_on_default_solar_pv_tuos_area_id"
    t.index ["default_template_calendar_id"], name: "index_school_groups_on_default_template_calendar_id"
  end

  create_table "school_key_stages", id: false, force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "key_stage_id", null: false
    t.index ["key_stage_id"], name: "index_school_key_stages_on_key_stage_id"
    t.index ["school_id"], name: "index_school_key_stages_on_school_id"
  end

  create_table "school_meter_attributes", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "attribute_type", null: false
    t.json "input_data"
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "replaced_by_id"
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.jsonb "meter_types", default: []
    t.index ["school_id"], name: "index_school_meter_attributes_on_school_id"
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
    t.bigint "solar_pv_tuos_area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "dark_sky_area_id"
    t.bigint "template_calendar_id"
    t.bigint "scoreboard_id"
    t.bigint "weather_station_id"
    t.boolean "school_will_be_public", default: true
    t.integer "default_chart_preference", default: 0, null: false
    t.integer "country", default: 0, null: false
    t.index ["created_by_id"], name: "index_school_onboardings_on_created_by_id"
    t.index ["created_user_id"], name: "index_school_onboardings_on_created_user_id"
    t.index ["school_group_id"], name: "index_school_onboardings_on_school_group_id"
    t.index ["school_id"], name: "index_school_onboardings_on_school_id"
    t.index ["scoreboard_id"], name: "index_school_onboardings_on_scoreboard_id"
    t.index ["solar_pv_tuos_area_id"], name: "index_school_onboardings_on_solar_pv_tuos_area_id"
    t.index ["template_calendar_id"], name: "index_school_onboardings_on_template_calendar_id"
    t.index ["uuid"], name: "index_school_onboardings_on_uuid", unique: true
  end

  create_table "school_partners", force: :cascade do |t|
    t.bigint "school_id"
    t.bigint "partner_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id"], name: "index_school_partners_on_partner_id"
    t.index ["school_id"], name: "index_school_partners_on_school_id"
  end

  create_table "school_target_events", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.integer "event", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_school_target_events_on_school_id"
  end

  create_table "school_targets", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.date "target_date"
    t.date "start_date"
    t.float "electricity"
    t.float "gas"
    t.float "storage_heaters"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "revised_fuel_types", default: [], null: false, array: true
    t.datetime "report_last_generated"
    t.json "electricity_progress", default: {}
    t.json "gas_progress", default: {}
    t.json "storage_heaters_progress", default: {}
    t.jsonb "electricity_report", default: {}
    t.jsonb "gas_report", default: {}
    t.jsonb "storage_heaters_report", default: {}
    t.index ["school_id"], name: "index_school_targets_on_school_id"
  end

  create_table "school_times", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.integer "opening_time", default: 850
    t.integer "closing_time", default: 1520
    t.integer "day"
    t.integer "usage_type", default: 0, null: false
    t.integer "calendar_period", default: 0, null: false
    t.index ["school_id"], name: "index_school_times_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.integer "school_type", null: false
    t.text "address"
    t.string "postcode"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "urn", null: false
    t.integer "level", default: 0
    t.bigint "calendar_id"
    t.string "slug"
    t.bigint "temperature_area_id"
    t.bigint "met_office_area_id"
    t.integer "number_of_pupils"
    t.decimal "floor_area"
    t.bigint "solar_pv_tuos_area_id"
    t.bigint "school_group_id"
    t.bigint "dark_sky_area_id"
    t.boolean "indicated_has_solar_panels", default: false, null: false
    t.boolean "has_swimming_pool", default: false, null: false
    t.boolean "serves_dinners", default: false, null: false
    t.boolean "cooks_dinners_onsite", default: false, null: false
    t.boolean "cooks_dinners_for_other_schools", default: false, null: false
    t.integer "cooks_dinners_for_other_schools_count"
    t.integer "template_calendar_id"
    t.string "validation_cache_key", default: "initial"
    t.boolean "visible", default: false
    t.boolean "process_data", default: false
    t.bigint "scoreboard_id"
    t.boolean "indicated_has_storage_heaters", default: false
    t.integer "percentage_free_school_meals"
    t.date "activation_date"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.bigint "weather_station_id"
    t.boolean "public", default: true
    t.boolean "active", default: true
    t.date "removal_date"
    t.boolean "enable_targets_feature", default: true
    t.boolean "data_enabled", default: false
    t.boolean "bill_requested", default: false
    t.integer "chart_preference", default: 0, null: false
    t.integer "country", default: 0, null: false
    t.integer "funding_status", default: 0, null: false
    t.boolean "alternative_heating_oil", default: false, null: false
    t.integer "alternative_heating_oil_percent", default: 0
    t.text "alternative_heating_oil_notes"
    t.boolean "alternative_heating_lpg", default: false, null: false
    t.integer "alternative_heating_lpg_percent", default: 0
    t.text "alternative_heating_lpg_notes"
    t.boolean "alternative_heating_biomass", default: false, null: false
    t.integer "alternative_heating_biomass_percent", default: 0
    t.text "alternative_heating_biomass_notes"
    t.boolean "alternative_heating_district_heating", default: false, null: false
    t.integer "alternative_heating_district_heating_percent", default: 0
    t.text "alternative_heating_district_heating_notes"
    t.integer "region"
    t.bigint "local_authority_area_id"
    t.index ["calendar_id"], name: "index_schools_on_calendar_id"
    t.index ["latitude", "longitude"], name: "index_schools_on_latitude_and_longitude"
    t.index ["local_authority_area_id"], name: "index_schools_on_local_authority_area_id"
    t.index ["school_group_id"], name: "index_schools_on_school_group_id"
    t.index ["scoreboard_id"], name: "index_schools_on_scoreboard_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "scoreboards", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "academic_year_calendar_id"
    t.boolean "public", default: true
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
    t.boolean "message_for_no_pupil_accounts", default: true
    t.jsonb "temperature_recording_months", default: ["10", "11", "12", "1", "2", "3", "4"]
    t.integer "default_import_warning_days", default: 10
    t.jsonb "prices"
  end

  create_table "sms_records", force: :cascade do |t|
    t.bigint "alert_subscription_event_id"
    t.text "mobile_phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_subscription_event_id"], name: "index_sms_records_on_alert_subscription_event_id"
  end

  create_table "solar_edge_installations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "amr_data_feed_config_id", null: false
    t.text "site_id"
    t.text "api_key"
    t.text "mpan"
    t.json "information", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["amr_data_feed_config_id"], name: "index_solar_edge_installations_on_amr_data_feed_config_id"
    t.index ["school_id"], name: "index_solar_edge_installations_on_school_id"
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
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscription_generation_runs", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_subscription_generation_runs_on_school_id"
  end

  create_table "tariff_import_logs", force: :cascade do |t|
    t.text "source", null: false
    t.text "description"
    t.text "error_messages"
    t.date "start_date"
    t.date "end_date"
    t.datetime "import_time"
    t.integer "prices_imported", default: 0, null: false
    t.integer "prices_updated", default: 0, null: false
    t.integer "standing_charges_imported", default: 0, null: false
    t.integer "standing_charges_updated", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tariff_prices", force: :cascade do |t|
    t.bigint "meter_id"
    t.bigint "tariff_import_log_id"
    t.date "tariff_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "prices"
    t.index ["meter_id", "tariff_date"], name: "index_tariff_prices_on_meter_id_and_tariff_date", unique: true
    t.index ["meter_id"], name: "index_tariff_prices_on_meter_id"
    t.index ["tariff_import_log_id"], name: "index_tariff_prices_on_tariff_import_log_id"
  end

  create_table "tariff_standing_charges", force: :cascade do |t|
    t.bigint "meter_id"
    t.bigint "tariff_import_log_id"
    t.date "start_date", null: false
    t.decimal "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meter_id", "start_date"], name: "index_tariff_standing_charges_on_meter_id_and_start_date", unique: true
    t.index ["meter_id"], name: "index_tariff_standing_charges_on_meter_id"
    t.index ["tariff_import_log_id"], name: "index_tariff_standing_charges_on_tariff_import_log_id"
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "team_members", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0, null: false
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

  create_table "transifex_load_errors", force: :cascade do |t|
    t.string "record_type"
    t.bigint "record_id"
    t.string "error"
    t.bigint "transifex_load_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transifex_load_id"], name: "transifex_load_error_run_idx"
  end

  create_table "transifex_loads", force: :cascade do |t|
    t.integer "pushed", default: 0, null: false
    t.integer "pulled", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0, null: false
  end

  create_table "transifex_statuses", force: :cascade do |t|
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "tx_last_push"
    t.datetime "tx_last_pull"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id"], name: "index_transifex_statuses_uniqueness", unique: true
  end

  create_table "transport_survey_responses", force: :cascade do |t|
    t.bigint "transport_survey_id", null: false
    t.bigint "transport_type_id", null: false
    t.integer "passengers", default: 1, null: false
    t.string "run_identifier", null: false
    t.datetime "surveyed_at", null: false
    t.integer "journey_minutes", default: 0, null: false
    t.integer "weather", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transport_survey_id"], name: "index_transport_survey_responses_on_transport_survey_id"
    t.index ["transport_type_id"], name: "index_transport_survey_responses_on_transport_type_id"
  end

  create_table "transport_surveys", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.date "run_on", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id", "run_on"], name: "index_transport_surveys_on_school_id_and_run_on", unique: true
    t.index ["school_id"], name: "index_transport_surveys_on_school_id"
  end

  create_table "transport_types", force: :cascade do |t|
    t.string "name"
    t.string "image", null: false
    t.decimal "kg_co2e_per_km", default: "0.0", null: false
    t.decimal "speed_km_per_hour", default: "0.0", null: false
    t.string "note"
    t.boolean "can_share", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "park_and_stride", default: false, null: false
    t.integer "category"
    t.integer "position", default: 0, null: false
    t.index ["name"], name: "index_transport_types_on_name", unique: true
  end

  create_table "user_tariff_charges", force: :cascade do |t|
    t.bigint "user_tariff_id", null: false
    t.text "charge_type", null: false
    t.decimal "value", null: false
    t.text "units"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_tariff_id"], name: "index_user_tariff_charges_on_user_tariff_id"
  end

  create_table "user_tariff_prices", force: :cascade do |t|
    t.bigint "user_tariff_id", null: false
    t.decimal "value", null: false
    t.text "units", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.time "start_time", default: "2000-01-01 00:00:00", null: false
    t.time "end_time", default: "2000-01-01 23:30:00", null: false
    t.string "description"
    t.index ["user_tariff_id"], name: "index_user_tariff_prices_on_user_tariff_id"
  end

  create_table "user_tariffs", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.text "name", null: false
    t.text "fuel_type", null: false
    t.boolean "flat_rate", default: true
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "vat_rate"
    t.boolean "ccl", default: false
    t.boolean "tnuos", default: false
    t.index ["school_id"], name: "index_user_tariffs_on_school_id"
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
    t.string "unlock_token"
    t.string "preferred_locale", default: "en", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_group_id"], name: "index_users_on_school_group_id"
    t.index ["school_id", "pupil_password"], name: "index_users_on_school_id_and_pupil_password", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["staff_role_id"], name: "index_users_on_staff_role_id"
  end

  create_table "videos", force: :cascade do |t|
    t.text "youtube_id", null: false
    t.text "title", null: false
    t.text "description"
    t.boolean "featured", default: true, null: false
    t.integer "position", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "weather_observations", force: :cascade do |t|
    t.bigint "weather_station_id", null: false
    t.date "reading_date", null: false
    t.decimal "temperature_celsius_x48", null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["weather_station_id", "reading_date"], name: "index_weather_obs_on_weather_station_id_and_reading_date", unique: true
    t.index ["weather_station_id"], name: "index_weather_observations_on_weather_station_id"
  end

  create_table "weather_stations", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.string "provider", null: false
    t.boolean "active", default: true
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "back_fill_years", default: 4
  end

  add_foreign_key "academic_years", "calendars", on_delete: :restrict
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "activity_categories", on_delete: :restrict
  add_foreign_key "activities", "activity_types", on_delete: :restrict
  add_foreign_key "activities", "schools", on_delete: :cascade
  add_foreign_key "activity_type_impacts", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_impacts", "impacts", on_delete: :restrict
  add_foreign_key "activity_type_key_stages", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_key_stages", "key_stages", on_delete: :restrict
  add_foreign_key "activity_type_subjects", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_subjects", "subjects", on_delete: :restrict
  add_foreign_key "activity_type_suggestions", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_timings", "activity_timings", on_delete: :restrict
  add_foreign_key "activity_type_timings", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_topics", "activity_types", on_delete: :cascade
  add_foreign_key "activity_type_topics", "topics", on_delete: :restrict
  add_foreign_key "activity_types", "activity_categories"
  add_foreign_key "advice_page_school_benchmarks", "advice_pages", on_delete: :cascade
  add_foreign_key "advice_page_school_benchmarks", "schools", on_delete: :cascade
  add_foreign_key "alert_errors", "alert_generation_runs", on_delete: :cascade
  add_foreign_key "alert_errors", "alert_types", on_delete: :cascade
  add_foreign_key "alert_generation_runs", "schools", on_delete: :cascade
  add_foreign_key "alert_subscription_events", "alert_type_rating_content_versions", on_delete: :cascade
  add_foreign_key "alert_subscription_events", "alerts", on_delete: :cascade
  add_foreign_key "alert_subscription_events", "contacts", on_delete: :cascade
  add_foreign_key "alert_subscription_events", "emails", on_delete: :nullify
  add_foreign_key "alert_subscription_events", "find_out_mores", on_delete: :nullify
  add_foreign_key "alert_subscription_events", "subscription_generation_runs", on_delete: :cascade
  add_foreign_key "alert_type_rating_activity_types", "alert_type_ratings", on_delete: :cascade
  add_foreign_key "alert_type_rating_content_versions", "alert_type_ratings", on_delete: :cascade
  add_foreign_key "alert_type_rating_intervention_types", "alert_type_ratings"
  add_foreign_key "alert_type_rating_intervention_types", "intervention_types"
  add_foreign_key "alert_type_rating_unsubscriptions", "alert_subscription_events", on_delete: :cascade
  add_foreign_key "alert_type_rating_unsubscriptions", "alert_type_ratings", on_delete: :cascade
  add_foreign_key "alert_type_rating_unsubscriptions", "contacts", on_delete: :cascade
  add_foreign_key "alert_type_ratings", "alert_types", on_delete: :cascade
  add_foreign_key "alerts", "alert_generation_runs", on_delete: :cascade
  add_foreign_key "alerts", "alert_types", on_delete: :cascade
  add_foreign_key "alerts", "schools", on_delete: :cascade
  add_foreign_key "amr_data_feed_readings", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "amr_data_feed_readings", "amr_data_feed_import_logs", on_delete: :cascade
  add_foreign_key "amr_data_feed_readings", "meters", on_delete: :nullify
  add_foreign_key "amr_reading_warnings", "amr_data_feed_import_logs", on_delete: :cascade
  add_foreign_key "amr_uploaded_readings", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "amr_validated_readings", "meters", on_delete: :cascade
  add_foreign_key "analysis_pages", "alert_type_rating_content_versions", on_delete: :restrict
  add_foreign_key "analysis_pages", "alerts", on_delete: :cascade
  add_foreign_key "analysis_pages", "content_generation_runs", on_delete: :cascade
  add_foreign_key "audits", "schools", on_delete: :cascade
  add_foreign_key "benchmark_result_errors", "alert_types", on_delete: :cascade
  add_foreign_key "benchmark_result_errors", "benchmark_result_school_generation_runs", on_delete: :cascade
  add_foreign_key "benchmark_result_school_generation_runs", "benchmark_result_generation_runs", on_delete: :cascade
  add_foreign_key "benchmark_result_school_generation_runs", "schools", on_delete: :cascade
  add_foreign_key "benchmark_results", "alert_types", on_delete: :cascade
  add_foreign_key "benchmark_results", "benchmark_result_school_generation_runs", on_delete: :cascade
  add_foreign_key "cads", "meters"
  add_foreign_key "cads", "schools", on_delete: :cascade
  add_foreign_key "calendar_events", "academic_years", on_delete: :restrict
  add_foreign_key "calendar_events", "calendar_event_types", on_delete: :restrict
  add_foreign_key "calendar_events", "calendars", on_delete: :cascade
  add_foreign_key "calendars", "calendars", column: "based_on_id", on_delete: :restrict
  add_foreign_key "cluster_schools_users", "schools", on_delete: :cascade
  add_foreign_key "cluster_schools_users", "users", on_delete: :cascade
  add_foreign_key "configurations", "schools", on_delete: :cascade
  add_foreign_key "consent_grants", "consent_statements"
  add_foreign_key "consent_grants", "schools"
  add_foreign_key "consent_grants", "users"
  add_foreign_key "contacts", "schools", on_delete: :cascade
  add_foreign_key "contacts", "staff_roles", on_delete: :restrict
  add_foreign_key "contacts", "users", on_delete: :cascade
  add_foreign_key "content_generation_runs", "schools", on_delete: :cascade
  add_foreign_key "dark_sky_temperature_readings", "areas", on_delete: :cascade
  add_foreign_key "dashboard_alerts", "alert_type_rating_content_versions", on_delete: :restrict
  add_foreign_key "dashboard_alerts", "alerts", on_delete: :cascade
  add_foreign_key "dashboard_alerts", "content_generation_runs", on_delete: :cascade
  add_foreign_key "dashboard_alerts", "find_out_mores", on_delete: :nullify
  add_foreign_key "emails", "contacts", on_delete: :cascade
  add_foreign_key "equivalence_type_content_versions", "equivalence_type_content_versions", column: "replaced_by_id", on_delete: :nullify
  add_foreign_key "equivalence_type_content_versions", "equivalence_types", on_delete: :cascade
  add_foreign_key "equivalences", "equivalence_type_content_versions", on_delete: :cascade
  add_foreign_key "equivalences", "schools", on_delete: :cascade
  add_foreign_key "estimated_annual_consumptions", "schools"
  add_foreign_key "find_out_mores", "alert_type_rating_content_versions", on_delete: :cascade
  add_foreign_key "find_out_mores", "alerts", on_delete: :cascade
  add_foreign_key "find_out_mores", "content_generation_runs", on_delete: :cascade
  add_foreign_key "global_meter_attributes", "global_meter_attributes", column: "replaced_by_id", on_delete: :nullify
  add_foreign_key "global_meter_attributes", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "global_meter_attributes", "users", column: "deleted_by_id", on_delete: :restrict
  add_foreign_key "intervention_type_suggestions", "intervention_types", on_delete: :cascade
  add_foreign_key "intervention_types", "intervention_type_groups", on_delete: :cascade
  add_foreign_key "issue_meters", "issues"
  add_foreign_key "issue_meters", "meters"
  add_foreign_key "issues", "users", column: "created_by_id"
  add_foreign_key "issues", "users", column: "owned_by_id"
  add_foreign_key "issues", "users", column: "updated_by_id"
  add_foreign_key "locations", "schools", on_delete: :cascade
  add_foreign_key "low_carbon_hub_installations", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "low_carbon_hub_installations", "schools", on_delete: :cascade
  add_foreign_key "management_dashboard_tables", "alert_type_rating_content_versions", on_delete: :restrict
  add_foreign_key "management_dashboard_tables", "alerts", on_delete: :cascade
  add_foreign_key "management_dashboard_tables", "content_generation_runs", on_delete: :cascade
  add_foreign_key "management_priorities", "alert_type_rating_content_versions", on_delete: :restrict
  add_foreign_key "management_priorities", "alerts", on_delete: :cascade
  add_foreign_key "management_priorities", "content_generation_runs", on_delete: :cascade
  add_foreign_key "management_priorities", "find_out_mores", on_delete: :nullify
  add_foreign_key "manual_data_load_run_log_entries", "manual_data_load_runs"
  add_foreign_key "manual_data_load_runs", "amr_uploaded_readings"
  add_foreign_key "meter_attributes", "meter_attributes", column: "replaced_by_id", on_delete: :nullify
  add_foreign_key "meter_attributes", "meters", on_delete: :cascade
  add_foreign_key "meter_attributes", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "meter_attributes", "users", column: "deleted_by_id", on_delete: :nullify
  add_foreign_key "meter_reviews", "consent_grants"
  add_foreign_key "meter_reviews", "schools"
  add_foreign_key "meter_reviews", "users"
  add_foreign_key "meters", "low_carbon_hub_installations", on_delete: :cascade
  add_foreign_key "meters", "meter_reviews"
  add_foreign_key "meters", "schools", on_delete: :cascade
  add_foreign_key "meters", "solar_edge_installations", on_delete: :cascade
  add_foreign_key "observations", "activities", on_delete: :nullify
  add_foreign_key "observations", "audits"
  add_foreign_key "observations", "intervention_types", on_delete: :restrict
  add_foreign_key "observations", "school_targets"
  add_foreign_key "observations", "schools", on_delete: :cascade
  add_foreign_key "programmes", "programme_types", on_delete: :cascade
  add_foreign_key "programmes", "schools", on_delete: :cascade
  add_foreign_key "resource_files", "resource_file_types", on_delete: :restrict
  add_foreign_key "rtone_variant_installations", "amr_data_feed_configs"
  add_foreign_key "rtone_variant_installations", "meters"
  add_foreign_key "rtone_variant_installations", "schools"
  add_foreign_key "school_alert_type_exclusions", "alert_types", on_delete: :cascade
  add_foreign_key "school_alert_type_exclusions", "schools", on_delete: :cascade
  add_foreign_key "school_batch_run_log_entries", "school_batch_runs", on_delete: :cascade
  add_foreign_key "school_batch_runs", "schools", on_delete: :cascade
  add_foreign_key "school_group_meter_attributes", "school_group_meter_attributes", column: "replaced_by_id", on_delete: :nullify
  add_foreign_key "school_group_meter_attributes", "school_groups", on_delete: :cascade
  add_foreign_key "school_group_meter_attributes", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "school_group_meter_attributes", "users", column: "deleted_by_id", on_delete: :nullify
  add_foreign_key "school_groups", "areas", column: "default_solar_pv_tuos_area_id"
  add_foreign_key "school_groups", "calendars", column: "default_template_calendar_id", on_delete: :nullify
  add_foreign_key "school_groups", "scoreboards", column: "default_scoreboard_id"
  add_foreign_key "school_groups", "users", column: "default_issues_admin_user_id", on_delete: :nullify
  add_foreign_key "school_key_stages", "key_stages", on_delete: :restrict
  add_foreign_key "school_key_stages", "schools", on_delete: :cascade
  add_foreign_key "school_meter_attributes", "school_meter_attributes", column: "replaced_by_id", on_delete: :nullify
  add_foreign_key "school_meter_attributes", "schools", on_delete: :cascade
  add_foreign_key "school_meter_attributes", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "school_meter_attributes", "users", column: "deleted_by_id", on_delete: :nullify
  add_foreign_key "school_onboarding_events", "school_onboardings", on_delete: :cascade
  add_foreign_key "school_onboardings", "areas", column: "solar_pv_tuos_area_id", on_delete: :restrict
  add_foreign_key "school_onboardings", "calendars", column: "template_calendar_id", on_delete: :nullify
  add_foreign_key "school_onboardings", "school_groups", on_delete: :restrict
  add_foreign_key "school_onboardings", "schools", on_delete: :cascade
  add_foreign_key "school_onboardings", "scoreboards", on_delete: :nullify
  add_foreign_key "school_onboardings", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "school_onboardings", "users", column: "created_user_id", on_delete: :nullify
  add_foreign_key "school_target_events", "schools", on_delete: :cascade
  add_foreign_key "school_targets", "schools"
  add_foreign_key "school_times", "schools", on_delete: :cascade
  add_foreign_key "schools", "calendars", on_delete: :restrict
  add_foreign_key "schools", "school_groups", on_delete: :restrict
  add_foreign_key "schools", "scoreboards", on_delete: :nullify
  add_foreign_key "scoreboards", "calendars", column: "academic_year_calendar_id", on_delete: :nullify
  add_foreign_key "simulations", "schools", on_delete: :cascade
  add_foreign_key "simulations", "users", on_delete: :nullify
  add_foreign_key "sms_records", "alert_subscription_events", on_delete: :cascade
  add_foreign_key "solar_edge_installations", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "solar_edge_installations", "schools", on_delete: :cascade
  add_foreign_key "solar_pv_tuos_readings", "areas", on_delete: :cascade
  add_foreign_key "subscription_generation_runs", "schools", on_delete: :cascade
  add_foreign_key "temperature_recordings", "locations", on_delete: :cascade
  add_foreign_key "temperature_recordings", "observations", on_delete: :cascade
  add_foreign_key "transifex_load_errors", "transifex_loads"
  add_foreign_key "transport_survey_responses", "transport_surveys", on_delete: :cascade
  add_foreign_key "transport_survey_responses", "transport_types"
  add_foreign_key "transport_surveys", "schools", on_delete: :cascade
  add_foreign_key "user_tariff_charges", "user_tariffs", on_delete: :cascade
  add_foreign_key "user_tariff_prices", "user_tariffs", on_delete: :cascade
  add_foreign_key "users", "school_groups", on_delete: :restrict
  add_foreign_key "users", "schools", on_delete: :cascade
  add_foreign_key "users", "staff_roles", on_delete: :restrict
  add_foreign_key "weather_observations", "weather_stations", on_delete: :cascade
end
