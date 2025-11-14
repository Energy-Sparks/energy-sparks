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

ActiveRecord::Schema[7.2].define(version: 2025_11_14_132029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
  enable_extension "pgstattuple"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "amr_data_feed_config_convert_to_kwh", ["no", "m3", "meter"]
  create_enum "audience", ["anyone", "school_users", "school_admins", "group_admins"]
  create_enum "data_sharing", ["public", "within_group", "private"]
  create_enum "dcc_meter", ["no", "smets2", "other"]
  create_enum "gas_unit", ["kwh", "m3", "ft3", "hcf"]
  create_enum "half_hourly_labelling", ["start", "end"]
  create_enum "mailchimp_status", ["subscribed", "unsubscribed", "cleaned", "nonsubscribed", "archived"]
  create_enum "meter_monthly_summary_quality", ["incomplete", "actual", "estimated", "corrected"]
  create_enum "meter_monthly_summary_type", ["consumption", "generation", "self_consume", "export"]
  create_enum "meter_perse_api", ["half_hourly"]
  create_enum "school_grouping_role", ["organisation", "area", "project"]

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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "locale", default: "en", null: false
    t.index ["record_type", "record_id", "name", "locale"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "activity_type_id", null: false
    t.string "title"
    t.text "deprecated_description"
    t.date "happened_on"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "activity_category_id"
    t.integer "pupil_count"
    t.bigint "updated_by_id"
    t.index ["activity_category_id"], name: "index_activities_on_activity_category_id"
    t.index ["activity_type_id"], name: "index_activities_on_activity_type_id"
    t.index ["school_id"], name: "index_activities_on_school_id"
    t.index ["updated_by_id"], name: "index_activities_on_updated_by_id"
  end

  create_table "activity_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "description"
    t.boolean "featured", default: false
    t.boolean "pupil", default: false
    t.boolean "live_data", default: false
    t.string "icon", default: "clipboard-check"
  end

  create_table "activity_timings", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "activity_category_id", null: false
    t.integer "score"
    t.boolean "data_driven", default: false
    t.boolean "custom", default: false
    t.string "summary"
    t.boolean "show_on_charts", default: true
    t.string "fuel_type", default: [], array: true
    t.integer "maximum_frequency", default: 10
    t.index ["active"], name: "index_activity_types_on_active"
    t.index ["activity_category_id"], name: "index_activity_types_on_activity_category_id"
  end

  create_table "admin_meter_statuses", force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ignore_in_inactive_meter_report", default: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["advice_page_id"], name: "index_advice_page_school_benchmarks_on_advice_page_id"
    t.index ["school_id"], name: "index_advice_page_school_benchmarks_on_school_id"
  end

  create_table "advice_pages", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "restricted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fuel_type"
    t.boolean "multiple_meters", default: false, null: false
    t.index ["key"], name: "index_advice_pages_on_key", unique: true
  end

  create_table "alert_errors", force: :cascade do |t|
    t.bigint "alert_generation_run_id", null: false
    t.bigint "alert_type_id", null: false
    t.date "asof_date", null: false
    t.text "information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "comparison_report_id"
    t.index ["alert_generation_run_id"], name: "index_alert_errors_on_alert_generation_run_id"
    t.index ["alert_type_id"], name: "index_alert_errors_on_alert_type_id"
    t.index ["comparison_report_id"], name: "index_alert_errors_on_comparison_report_id"
  end

  create_table "alert_generation_runs", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "created_at"], name: "index_alert_generation_runs_on_school_id_and_created_at", order: { created_at: :desc }
    t.index ["school_id"], name: "index_alert_generation_runs_on_school_id"
  end

  create_table "alert_subscription_events", force: :cascade do |t|
    t.bigint "alert_id", null: false
    t.bigint "contact_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "communication_type", default: 0, null: false
    t.text "message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.date "management_dashboard_table_start_date"
    t.date "management_dashboard_table_end_date"
    t.decimal "management_dashboard_table_weighting", default: "5.0"
    t.date "group_dashboard_alert_start_date"
    t.date "group_dashboard_alert_end_date"
    t.decimal "group_dashboard_alert_weighting", default: "5.0"
    t.index ["alert_type_rating_id"], name: "fom_content_v_fom_id"
  end

  create_table "alert_type_rating_intervention_types", force: :cascade do |t|
    t.bigint "intervention_type_id", null: false
    t.bigint "alert_type_rating_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_subscription_event_id"], name: "altunsub_event"
    t.index ["alert_type_rating_id"], name: "index_alert_type_rating_unsubscriptions_on_alert_type_rating_id"
    t.index ["contact_id"], name: "index_alert_type_rating_unsubscriptions_on_contact_id"
  end

  create_table "alert_type_ratings", force: :cascade do |t|
    t.bigint "alert_type_id", null: false
    t.decimal "rating_from", null: false
    t.decimal "rating_to", null: false
    t.string "description", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "sms_active", default: false
    t.boolean "email_active", default: false
    t.boolean "find_out_more_active", default: false
    t.boolean "pupil_dashboard_alert_active", default: false
    t.boolean "public_dashboard_alert_active", default: false
    t.boolean "management_dashboard_alert_active", default: false
    t.boolean "management_priorities_active", default: false
    t.boolean "management_dashboard_table_active", default: false
    t.boolean "group_dashboard_alert_active", default: false
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
    t.index ["class_name"], name: "index_alert_types_on_class_name"
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "alert_type_id", null: false
    t.date "run_on"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.jsonb "variables"
    t.integer "reporting_period"
    t.bigint "comparison_report_id"
    t.index ["alert_generation_run_id"], name: "index_alerts_on_alert_generation_run_id"
    t.index ["alert_type_id", "created_at"], name: "index_alerts_on_alert_type_id_and_created_at"
    t.index ["alert_type_id"], name: "index_alerts_on_alert_type_id"
    t.index ["comparison_report_id"], name: "index_alerts_on_comparison_report_id"
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.boolean "enabled", default: true, null: false
    t.text "reading_time_field"
    t.enum "convert_to_kwh", default: "no", enum_type: "amr_data_feed_config_convert_to_kwh"
    t.boolean "delayed_reading", default: false, null: false
    t.enum "half_hourly_labelling", enum_type: "half_hourly_labelling"
    t.boolean "allow_merging", default: false, null: false
    t.integer "missing_reading_window", default: 5
    t.bigint "owned_by_id"
    t.index ["description"], name: "index_amr_data_feed_configs_on_description", unique: true
    t.index ["identifier"], name: "index_amr_data_feed_configs_on_identifier", unique: true
    t.index ["owned_by_id"], name: "index_amr_data_feed_configs_on_owned_by_id"
  end

  create_table "amr_data_feed_import_logs", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id", null: false
    t.text "file_name"
    t.datetime "import_time", precision: nil
    t.integer "records_imported"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "reading_time"
    t.index ["amr_data_feed_config_id"], name: "index_amr_data_feed_readings_on_amr_data_feed_config_id"
    t.index ["amr_data_feed_import_log_id"], name: "index_amr_data_feed_readings_on_amr_data_feed_import_log_id"
    t.index ["created_at", "meter_id"], name: "index_amr_data_feed_readings_on_created_at_and_meter_id"
    t.index ["meter_id", "amr_data_feed_config_id"], name: "adfr_meter_id_config_id"
    t.index ["meter_id"], name: "index_amr_data_feed_readings_on_meter_id"
    t.index ["mpan_mprn"], name: "index_amr_data_feed_readings_on_mpan_mprn"
    t.unique_constraint ["mpan_mprn", "reading_date"], name: "unique_meter_readings"
  end

  create_table "amr_reading_warnings", force: :cascade do |t|
    t.bigint "amr_data_feed_import_log_id", null: false
    t.integer "warning"
    t.text "warning_message"
    t.text "reading_date"
    t.text "mpan_mprn"
    t.text "readings", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amr_data_feed_config_id"], name: "index_amr_uploaded_readings_on_amr_data_feed_config_id"
  end

  create_table "amr_validated_readings", force: :cascade do |t|
    t.bigint "meter_id", null: false
    t.decimal "kwh_data_x48", null: false, array: true
    t.decimal "one_day_kwh", null: false
    t.date "reading_date", null: false
    t.text "status", null: false
    t.date "substitute_date"
    t.datetime "upload_datetime", precision: nil
    t.index ["meter_id", "one_day_kwh"], name: "index_amr_validated_readings_on_meter_id_and_one_day_kwh"
    t.index ["reading_date"], name: "index_amr_validated_readings_on_reading_date"
    t.unique_constraint ["meter_id", "reading_date"], name: "unique_amr_meter_validated_readings"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "involved_pupils", default: false, null: false
    t.index ["school_id"], name: "index_audits_on_school_id"
  end

  create_table "cads", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "name", null: false
    t.string "device_identifier", null: false
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", default: -> { "(CURRENT_TIMESTAMP - 'P1M'::interval)" }, null: false
    t.datetime "updated_at", default: -> { "(CURRENT_TIMESTAMP - 'P1M'::interval)" }, null: false
    t.index ["academic_year_id"], name: "index_calendar_events_on_academic_year_id"
    t.index ["calendar_event_type_id"], name: "index_calendar_events_on_calendar_event_type_id"
    t.index ["calendar_id"], name: "index_calendar_events_on_calendar_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "based_on_id"
    t.integer "calendar_type"
    t.index ["based_on_id"], name: "index_calendars_on_based_on_id"
  end

  create_table "carbon_intensity_readings", force: :cascade do |t|
    t.date "reading_date", null: false
    t.decimal "carbon_intensity_x48", null: false, array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["reading_date"], name: "index_carbon_intensity_readings_on_reading_date", unique: true
  end

  create_table "case_studies", force: :cascade do |t|
    t.string "title"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_case_studies_on_created_by_id"
    t.index ["updated_by_id"], name: "index_case_studies_on_updated_by_id"
  end

  create_table "cluster_schools_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_cluster_schools_users_on_school_id"
    t.index ["user_id", "school_id"], name: "index_cluster_schools_users_on_user_id_and_school_id"
    t.index ["user_id"], name: "index_cluster_schools_users_on_user_id"
  end

  create_table "cms_categories", force: :cascade do |t|
    t.string "icon", default: "question"
    t.string "slug", null: false
    t.boolean "published", default: false, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_cms_categories_on_created_by_id"
    t.index ["updated_by_id"], name: "index_cms_categories_on_updated_by_id"
  end

  create_table "cms_pages", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "slug", null: false
    t.boolean "published", default: false, null: false
    t.enum "audience", default: "anyone", null: false, enum_type: "audience"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_cms_pages_on_category_id"
    t.index ["created_by_id"], name: "index_cms_pages_on_created_by_id"
    t.index ["updated_by_id"], name: "index_cms_pages_on_updated_by_id"
  end

  create_table "cms_sections", force: :cascade do |t|
    t.bigint "page_id"
    t.string "slug", null: false
    t.integer "position"
    t.boolean "published", default: false, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_cms_sections_on_created_by_id"
    t.index ["page_id"], name: "index_cms_sections_on_page_id"
    t.index ["updated_by_id"], name: "index_cms_sections_on_updated_by_id"
  end

  create_table "comparison_custom_periods", force: :cascade do |t|
    t.string "current_label", null: false
    t.date "current_start_date", null: false
    t.date "current_end_date", null: false
    t.string "previous_label", null: false
    t.date "previous_start_date", null: false
    t.date "previous_end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_days_out_of_date"
    t.integer "enough_days_data"
    t.boolean "disable_normalisation", default: false, null: false
  end

  create_table "comparison_footnotes", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label"
    t.index ["key"], name: "index_comparison_footnotes_on_key", unique: true
  end

  create_table "comparison_report_groups", force: :cascade do |t|
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comparison_reports", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "public", default: false
    t.integer "reporting_period"
    t.bigint "custom_period_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "report_group_id"
    t.boolean "disabled", default: false, null: false
    t.integer "fuel_type"
    t.index ["custom_period_id"], name: "index_comparison_reports_on_custom_period_id"
    t.index ["key"], name: "index_comparison_reports_on_key", unique: true
    t.index ["report_group_id"], name: "index_comparison_reports_on_report_group_id"
  end

  create_table "completed_todos", force: :cascade do |t|
    t.bigint "todo_id", null: false
    t.string "completable_type", null: false
    t.bigint "completable_id", null: false
    t.string "recording_type", null: false
    t.bigint "recording_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completable_type", "completable_id"], name: "index_completed_todos_on_completable"
    t.index ["recording_type", "recording_id"], name: "index_completed_todos_on_recording"
    t.index ["todo_id"], name: "index_completed_todos_on_todo_id"
  end

  create_table "configurations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.json "analysis_charts", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consent_statement_id"], name: "index_consent_grants_on_consent_statement_id"
    t.index ["school_id"], name: "index_consent_grants_on_school_id"
    t.index ["user_id"], name: "index_consent_grants_on_user_id"
  end

  create_table "consent_statements", force: :cascade do |t|
    t.text "title", null: false
    t.boolean "current", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["school_id"], name: "index_content_generation_runs_on_school_id"
  end

  create_table "dark_sky_temperature_readings", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.date "reading_date", null: false
    t.decimal "temperature_celsius_x48", null: false, array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["area_id", "reading_date"], name: "index_dark_sky_temperature_readings_on_area_id_and_reading_date", unique: true
    t.index ["area_id"], name: "index_dark_sky_temperature_readings_on_area_id"
  end

  create_table "dashboard_alerts", force: :cascade do |t|
    t.integer "dashboard", null: false
    t.bigint "content_generation_run_id", null: false
    t.bigint "alert_id", null: false
    t.bigint "alert_type_rating_content_version_id", null: false
    t.bigint "find_out_more_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "import_warning_days"
    t.boolean "load_tariffs", default: true, null: false
  end

  create_table "emails", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "sent_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["contact_id"], name: "index_emails_on_contact_id"
  end

  create_table "energy_tariff_charges", force: :cascade do |t|
    t.bigint "energy_tariff_id", null: false
    t.text "charge_type", null: false
    t.decimal "value", null: false
    t.text "units"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["energy_tariff_id"], name: "index_energy_tariff_charges_on_energy_tariff_id"
  end

  create_table "energy_tariff_prices", force: :cascade do |t|
    t.bigint "energy_tariff_id", null: false
    t.time "start_time", default: "2000-01-01 00:00:00", null: false
    t.time "end_time", default: "2000-01-01 23:30:00", null: false
    t.decimal "value"
    t.text "units"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["energy_tariff_id"], name: "index_energy_tariff_prices_on_energy_tariff_id"
  end

  create_table "energy_tariffs", force: :cascade do |t|
    t.string "tariff_holder_type"
    t.bigint "tariff_holder_id"
    t.integer "source", default: 0, null: false
    t.integer "meter_type", default: 0, null: false
    t.integer "tariff_type", default: 0, null: false
    t.text "name", null: false
    t.date "start_date"
    t.date "end_date"
    t.boolean "enabled", default: true
    t.boolean "ccl", default: false
    t.boolean "tnuos", default: false
    t.integer "vat_rate"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "applies_to", default: 0
    t.index ["created_by_id"], name: "index_energy_tariffs_on_created_by_id"
    t.index ["tariff_holder_type", "tariff_holder_id"], name: "index_energy_tariffs_on_tariff_holder_type_and_tariff_holder_id"
    t.index ["updated_by_id"], name: "index_energy_tariffs_on_updated_by_id"
  end

  create_table "energy_tariffs_meters", id: false, force: :cascade do |t|
    t.bigint "meter_id"
    t.bigint "energy_tariff_id"
    t.index ["energy_tariff_id"], name: "index_energy_tariffs_meters_on_energy_tariff_id"
    t.index ["meter_id"], name: "index_energy_tariffs_meters_on_meter_id"
  end

  create_table "equivalence_type_content_versions", force: :cascade do |t|
    t.bigint "equivalence_type_id", null: false
    t.bigint "replaced_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equivalence_type_id"], name: "index_equivalence_type_content_versions_on_equivalence_type_id"
    t.index ["replaced_by_id"], name: "eqtcv_eqtcv_repl"
  end

  create_table "equivalence_types", force: :cascade do |t|
    t.integer "meter_type", null: false
    t.integer "time_period", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "image_name", default: 0, null: false
  end

  create_table "equivalences", force: :cascade do |t|
    t.bigint "equivalence_type_content_version_id", null: false
    t.bigint "school_id", null: false
    t.json "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_estimated_annual_consumptions_on_school_id"
  end

  create_table "find_out_mores", force: :cascade do |t|
    t.bigint "alert_type_rating_content_version_id", null: false
    t.bigint "alert_id", null: false
    t.bigint "content_generation_run_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["alert_id"], name: "index_find_out_mores_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "fom_fom_content_v_id"
    t.index ["content_generation_run_id"], name: "index_find_out_mores_on_content_generation_run_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "funders", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "mailchimp_fields_changed_at"
  end

  create_table "global_meter_attributes", force: :cascade do |t|
    t.string "attribute_type", null: false
    t.json "input_data"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "replaced_by_id"
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.jsonb "meter_types", default: []
    t.index ["created_by_id"], name: "index_global_meter_attributes_on_created_by_id"
    t.index ["deleted_by_id"], name: "index_global_meter_attributes_on_deleted_by_id"
    t.index ["replaced_by_id"], name: "index_global_meter_attributes_on_replaced_by_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at", precision: nil
    t.datetime "discarded_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at", precision: nil
    t.datetime "performed_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at", precision: nil
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "help_pages", force: :cascade do |t|
    t.string "title"
    t.integer "feature", null: false
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_help_pages_on_slug", unique: true
  end

  create_table "impacts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "intervention_type_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon", default: "question-circle"
    t.string "description"
    t.boolean "active", default: true
  end

  create_table "intervention_type_suggestions", force: :cascade do |t|
    t.bigint "intervention_type_id"
    t.integer "suggested_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.boolean "show_on_charts", default: true
    t.string "fuel_type", default: [], array: true
    t.integer "maximum_frequency", default: 10
    t.index ["intervention_type_group_id"], name: "index_intervention_types_on_intervention_type_group_id"
  end

  create_table "issue_meters", force: :cascade do |t|
    t.bigint "issue_id"
    t.bigint "meter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owned_by_id"
    t.boolean "pinned", default: false
    t.string "issueable_type"
    t.bigint "issueable_id"
    t.date "review_date"
    t.index ["created_by_id"], name: "index_issues_on_created_by_id"
    t.index ["issueable_type", "issueable_id"], name: "index_issues_on_issueable_type_and_issueable_id"
    t.index ["owned_by_id"], name: "index_issues_on_owned_by_id"
    t.index ["updated_by_id"], name: "index_issues_on_updated_by_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "voluntary", default: false
    t.date "closing_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rewriteable_type", "rewriteable_id"], name: "index_link_rewrites_on_rewriteable_type_and_rewriteable_id"
  end

  create_table "lists_establishment_links", primary_key: ["establishment_id", "linked_establishment_id"], force: :cascade do |t|
    t.string "link_name"
    t.string "link_type"
    t.datetime "link_established_date"
    t.bigint "establishment_id", null: false
    t.bigint "linked_establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_lists_establishment_links_on_establishment_id"
    t.index ["linked_establishment_id"], name: "index_lists_establishment_links_on_linked_establishment_id"
  end

  create_table "lists_establishments", force: :cascade do |t|
    t.integer "la_code"
    t.integer "establishment_number"
    t.string "establishment_name"
    t.integer "establishment_status_code"
    t.string "postcode"
    t.string "school_website"
    t.integer "type_of_establishment_code"
    t.string "uprn"
    t.integer "number_of_pupils"
    t.string "percentage_fsm"
    t.datetime "last_changed_date"
    t.integer "establishment_type_group_code"
    t.datetime "open_date"
    t.datetime "close_date"
    t.integer "phase_of_education_code"
    t.integer "statutory_low_age"
    t.integer "statutory_high_age"
    t.integer "boarders_code"
    t.string "nursery_provision_name"
    t.integer "official_sixth_form_code"
    t.string "diocese_code"
    t.integer "school_capacity"
    t.datetime "census_date"
    t.integer "trusts_code"
    t.integer "federations_code"
    t.integer "ukprn"
    t.string "street"
    t.string "locality"
    t.string "address3"
    t.string "town"
    t.string "county_name"
    t.string "gor_code"
    t.string "district_administrative_code"
    t.string "administrative_ward_code"
    t.string "parliamentary_constituency_code"
    t.string "urban_rural_code"
    t.string "gssla_code_name"
    t.integer "easting"
    t.integer "northing"
    t.integer "previous_la_code"
    t.string "msoa_code"
    t.string "lsoa_code"
    t.integer "fsm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "local_authority_areas", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "mailchimp_fields_changed_at"
  end

  create_table "local_distribution_zone_postcodes", force: :cascade do |t|
    t.bigint "local_distribution_zone_id"
    t.string "postcode"
    t.index ["local_distribution_zone_id"], name: "idx_on_local_distribution_zone_id_a9dfd2a021"
    t.index ["postcode"], name: "index_local_distribution_zone_postcodes_on_postcode", unique: true
  end

  create_table "local_distribution_zone_readings", force: :cascade do |t|
    t.date "date", null: false
    t.float "calorific_value", null: false
    t.bigint "local_distribution_zone_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_distribution_zone_id", "date"], name: "idx_on_local_distribution_zone_id_date_acca36ccf1", unique: true
    t.index ["local_distribution_zone_id"], name: "idx_on_local_distribution_zone_id_5bc550f347"
  end

  create_table "local_distribution_zones", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "publication_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_local_distribution_zones_on_code", unique: true
    t.index ["name"], name: "index_local_distribution_zones_on_name", unique: true
    t.index ["publication_id"], name: "index_local_distribution_zones_on_publication_id", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_locations_on_school_id"
  end

  create_table "low_carbon_hub_installations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "amr_data_feed_config_id", null: false
    t.text "rbee_meter_id"
    t.json "information", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "password"
    t.index ["amr_data_feed_config_id"], name: "index_low_carbon_hub_installations_on_amr_data_feed_config_id"
    t.index ["school_id"], name: "index_low_carbon_hub_installations_on_school_id"
  end

  create_table "management_dashboard_tables", force: :cascade do |t|
    t.bigint "content_generation_run_id"
    t.bigint "alert_id"
    t.bigint "alert_type_rating_content_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_management_dashboard_tables_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "man_dash_alert_content_version_index"
    t.index ["content_generation_run_id"], name: "index_management_dashboard_tables_on_content_generation_run_id"
  end

  create_table "management_priorities", force: :cascade do |t|
    t.bigint "content_generation_run_id", null: false
    t.bigint "alert_id", null: false
    t.bigint "find_out_more_id"
    t.bigint "alert_type_rating_content_version_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "priority", default: "0.0", null: false
    t.index ["alert_id"], name: "index_management_priorities_on_alert_id"
    t.index ["alert_type_rating_content_version_id"], name: "mp_altrcv"
    t.index ["content_generation_run_id"], name: "index_management_priorities_on_content_generation_run_id"
    t.index ["find_out_more_id"], name: "index_management_priorities_on_find_out_more_id"
  end

  create_table "manual_data_load_run_log_entries", force: :cascade do |t|
    t.bigint "manual_data_load_run_id", null: false
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manual_data_load_run_id"], name: "manual_data_load_run_log_idx"
  end

  create_table "manual_data_load_runs", force: :cascade do |t|
    t.bigint "amr_uploaded_reading_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amr_uploaded_reading_id"], name: "index_manual_data_load_runs_on_amr_uploaded_reading_id"
  end

  create_table "meter_attributes", force: :cascade do |t|
    t.bigint "meter_id", null: false
    t.string "attribute_type", null: false
    t.json "input_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reason"
    t.bigint "replaced_by_id"
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.index ["meter_id"], name: "index_meter_attributes_on_meter_id"
  end

  create_table "meter_monthly_summaries", force: :cascade do |t|
    t.bigint "meter_id", null: false
    t.integer "year", null: false
    t.enum "type", null: false, enum_type: "meter_monthly_summary_type"
    t.float "consumption", null: false, array: true
    t.enum "quality", null: false, array: true, enum_type: "meter_monthly_summary_quality"
    t.float "total", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id", "year", "type"], name: "index_meter_monthly_summaries_on_meter_id_and_year_and_type", unique: true
    t.index ["meter_id"], name: "index_meter_monthly_summaries_on_meter_id"
  end

  create_table "meter_reviews", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "user_id", null: false
    t.bigint "consent_grant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consent_grant_id"], name: "index_meter_reviews_on_consent_grant_id"
    t.index ["school_id"], name: "index_meter_reviews_on_school_id"
    t.index ["user_id"], name: "index_meter_reviews_on_user_id"
  end

  create_table "meters", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.integer "meter_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true
    t.string "name"
    t.bigint "mpan_mprn"
    t.text "meter_serial_number"
    t.bigint "low_carbon_hub_installation_id"
    t.boolean "pseudo", default: false
    t.bigint "solar_edge_installation_id"
    t.enum "dcc_meter", default: "no", null: false, enum_type: "dcc_meter"
    t.boolean "consent_granted", default: false
    t.bigint "meter_review_id"
    t.datetime "dcc_checked_at", precision: nil
    t.bigint "data_source_id"
    t.bigint "admin_meter_statuses_id"
    t.bigint "procurement_route_id"
    t.integer "meter_system", default: 0
    t.enum "perse_api", enum_type: "meter_perse_api"
    t.bigint "solis_cloud_installation_id"
    t.boolean "manual_reads", default: false, null: false
    t.enum "gas_unit", enum_type: "gas_unit"
    t.index ["data_source_id"], name: "index_meters_on_data_source_id"
    t.index ["low_carbon_hub_installation_id"], name: "index_meters_on_low_carbon_hub_installation_id"
    t.index ["meter_review_id"], name: "index_meters_on_meter_review_id"
    t.index ["meter_type"], name: "index_meters_on_meter_type"
    t.index ["mpan_mprn"], name: "index_meters_on_mpan_mprn", unique: true
    t.index ["procurement_route_id"], name: "index_meters_on_procurement_route_id"
    t.index ["school_id"], name: "index_meters_on_school_id"
    t.index ["solar_edge_installation_id"], name: "index_meters_on_solar_edge_installation_id"
    t.index ["solis_cloud_installation_id"], name: "index_meters_on_solis_cloud_installation_id"
  end

  create_table "mobility_string_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.string "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "newsletters", force: :cascade do |t|
    t.text "title", null: false
    t.text "url", null: false
    t.date "published_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_newsletters_on_created_by_id"
    t.index ["updated_by_id"], name: "index_newsletters_on_updated_by_id"
  end

  create_table "observations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "at", precision: nil, null: false
    t.text "_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "observation_type", null: false
    t.bigint "intervention_type_id"
    t.bigint "activity_id"
    t.integer "points"
    t.boolean "visible", default: true
    t.bigint "audit_id"
    t.boolean "involved_pupils", default: false, null: false
    t.bigint "school_target_id"
    t.bigint "programme_id"
    t.integer "pupil_count"
    t.string "observable_type"
    t.bigint "observable_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["activity_id"], name: "index_observations_on_activity_id"
    t.index ["audit_id"], name: "index_observations_on_audit_id"
    t.index ["created_by_id"], name: "index_observations_on_created_by_id"
    t.index ["intervention_type_id"], name: "index_observations_on_intervention_type_id"
    t.index ["observable_type", "observable_id"], name: "index_observations_on_observable_type_and_observable_id"
    t.index ["programme_id"], name: "index_observations_on_programme_id"
    t.index ["school_id"], name: "index_observations_on_school_id"
    t.index ["school_target_id"], name: "index_observations_on_school_target_id"
    t.index ["updated_by_id"], name: "index_observations_on_updated_by_id"
  end

  create_table "partners", force: :cascade do |t|
    t.integer "position", default: 0, null: false
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", default: "2022-07-06 12:00:00", null: false
    t.datetime "updated_at", default: "2022-07-06 12:00:00", null: false
    t.integer "bonus_score", default: 0
  end

  create_table "programmes", force: :cascade do |t|
    t.bigint "programme_type_id", null: false
    t.bigint "school_id", null: false
    t.integer "status", default: 0, null: false
    t.date "started_on", null: false
    t.date "ended_on"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["programme_type_id"], name: "index_programmes_on_programme_type_id"
    t.index ["school_id"], name: "index_programmes_on_school_id"
  end

  create_table "resource_file_types", force: :cascade do |t|
    t.string "title", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resource_files", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amr_data_feed_config_id"], name: "index_rtone_variant_installations_on_amr_data_feed_config_id"
    t.index ["meter_id"], name: "index_rtone_variant_installations_on_meter_id"
    t.index ["school_id"], name: "index_rtone_variant_installations_on_school_id"
  end

  create_table "school_alert_type_exclusions", force: :cascade do |t|
    t.bigint "alert_type_id"
    t.bigint "school_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.index ["alert_type_id"], name: "index_school_alert_type_exclusions_on_alert_type_id"
    t.index ["created_by_id"], name: "index_school_alert_type_exclusions_on_created_by_id"
    t.index ["school_id"], name: "index_school_alert_type_exclusions_on_school_id"
  end

  create_table "school_batch_run_log_entries", force: :cascade do |t|
    t.bigint "school_batch_run_id"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_batch_run_id"], name: "index_school_batch_run_log_entries_on_school_batch_run_id"
  end

  create_table "school_batch_runs", force: :cascade do |t|
    t.bigint "school_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_batch_runs_on_school_id"
  end

  create_table "school_group_clusters", force: :cascade do |t|
    t.string "name"
    t.bigint "school_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_group_id"], name: "index_school_group_clusters_on_school_group_id"
  end

  create_table "school_group_meter_attributes", force: :cascade do |t|
    t.bigint "school_group_id", null: false
    t.string "attribute_type", null: false
    t.json "input_data"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id"], name: "index_school_group_partners_on_partner_id"
    t.index ["school_group_id"], name: "index_school_group_partners_on_school_group_id"
  end

  create_table "school_groupings", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "school_group_id", null: false
    t.enum "role", null: false, enum_type: "school_grouping_role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_group_id"], name: "index_school_groupings_on_school_group_id"
    t.index ["school_id", "role"], name: "index_school_groupings_on_school_id_and_organisation_role", unique: true, where: "(role = 'organisation'::school_grouping_role)"
    t.index ["school_id"], name: "index_school_groupings_on_school_id"
  end

  create_table "school_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.bigint "default_scoreboard_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "mailchimp_fields_changed_at"
    t.string "dfe_code"
    t.index ["default_issues_admin_user_id"], name: "index_school_groups_on_default_issues_admin_user_id"
    t.index ["default_scoreboard_id"], name: "index_school_groups_on_default_scoreboard_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "replaced_by_id"
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.jsonb "meter_types", default: []
    t.index ["school_id"], name: "index_school_meter_attributes_on_school_id"
  end

  create_table "school_onboarding_events", force: :cascade do |t|
    t.bigint "school_onboarding_id", null: false
    t.integer "event", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "dark_sky_area_id"
    t.bigint "template_calendar_id"
    t.bigint "scoreboard_id"
    t.bigint "weather_station_id"
    t.boolean "school_will_be_public", default: true
    t.integer "default_chart_preference", default: 0, null: false
    t.integer "country", default: 0, null: false
    t.bigint "funder_id"
    t.enum "data_sharing", default: "public", null: false, enum_type: "data_sharing"
    t.integer "urn"
    t.boolean "full_school", default: true
    t.bigint "project_group_id"
    t.index ["created_by_id"], name: "index_school_onboardings_on_created_by_id"
    t.index ["created_user_id"], name: "index_school_onboardings_on_created_user_id"
    t.index ["funder_id"], name: "index_school_onboardings_on_funder_id"
    t.index ["project_group_id"], name: "index_school_onboardings_on_project_group_id"
    t.index ["school_group_id"], name: "index_school_onboardings_on_school_group_id"
    t.index ["school_id"], name: "index_school_onboardings_on_school_id"
    t.index ["scoreboard_id"], name: "index_school_onboardings_on_scoreboard_id"
    t.index ["template_calendar_id"], name: "index_school_onboardings_on_template_calendar_id"
    t.index ["uuid"], name: "index_school_onboardings_on_uuid", unique: true
  end

  create_table "school_partners", force: :cascade do |t|
    t.bigint "school_id"
    t.bigint "partner_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id"], name: "index_school_partners_on_partner_id"
    t.index ["school_id"], name: "index_school_partners_on_school_id"
  end

  create_table "school_target_events", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.integer "event", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_target_events_on_school_id"
  end

  create_table "school_targets", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.date "target_date"
    t.date "start_date"
    t.float "electricity"
    t.float "gas"
    t.float "storage_heaters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "revised_fuel_types", default: [], null: false, array: true
    t.datetime "report_last_generated", precision: nil
    t.json "electricity_progress", default: {}
    t.json "gas_progress", default: {}
    t.json "storage_heaters_progress", default: {}
    t.jsonb "electricity_report", default: {}
    t.jsonb "gas_report", default: {}
    t.jsonb "storage_heaters_report", default: {}
    t.jsonb "electricity_monthly_consumption"
    t.jsonb "gas_monthly_consumption"
    t.jsonb "storage_heaters_monthly_consumption"
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.boolean "heating_oil", default: false, null: false
    t.integer "heating_oil_percent", default: 0
    t.text "heating_oil_notes"
    t.boolean "heating_lpg", default: false, null: false
    t.integer "heating_lpg_percent", default: 0
    t.text "heating_lpg_notes"
    t.boolean "heating_biomass", default: false, null: false
    t.integer "heating_biomass_percent", default: 0
    t.text "heating_biomass_notes"
    t.boolean "heating_district_heating", default: false, null: false
    t.integer "heating_district_heating_percent", default: 0
    t.text "heating_district_heating_notes"
    t.integer "region"
    t.bigint "local_authority_area_id"
    t.datetime "bill_requested_at", precision: nil
    t.bigint "school_group_cluster_id"
    t.bigint "funder_id"
    t.boolean "heating_ground_source_heat_pump", default: false, null: false
    t.integer "heating_ground_source_heat_pump_percent", default: 0
    t.text "heating_ground_source_heat_pump_notes"
    t.boolean "heating_air_source_heat_pump", default: false, null: false
    t.integer "heating_air_source_heat_pump_percent", default: 0
    t.text "heating_air_source_heat_pump_notes"
    t.boolean "heating_water_source_heat_pump", default: false, null: false
    t.integer "heating_water_source_heat_pump_percent", default: 0
    t.text "heating_water_source_heat_pump_notes"
    t.date "archived_date"
    t.enum "data_sharing", default: "public", null: false, enum_type: "data_sharing"
    t.datetime "mailchimp_fields_changed_at"
    t.boolean "heating_gas", default: false, null: false
    t.integer "heating_gas_percent", default: 0
    t.text "heating_gas_notes"
    t.boolean "heating_electric", default: false, null: false
    t.integer "heating_electric_percent", default: 0
    t.text "heating_electric_notes"
    t.boolean "heating_underfloor", default: false, null: false
    t.integer "heating_underfloor_percent", default: 0
    t.text "heating_underfloor_notes"
    t.boolean "heating_chp", default: false, null: false
    t.integer "heating_chp_percent", default: 0
    t.text "heating_chp_notes"
    t.bigint "local_distribution_zone_id"
    t.bigint "establishment_id"
    t.boolean "full_school", default: true
    t.index ["calendar_id"], name: "index_schools_on_calendar_id"
    t.index ["establishment_id"], name: "index_schools_on_establishment_id"
    t.index ["latitude", "longitude"], name: "index_schools_on_latitude_and_longitude"
    t.index ["local_authority_area_id"], name: "index_schools_on_local_authority_area_id"
    t.index ["local_distribution_zone_id"], name: "index_schools_on_local_distribution_zone_id"
    t.index ["school_group_cluster_id"], name: "index_schools_on_school_group_cluster_id"
    t.index ["school_group_id"], name: "index_schools_on_school_group_id"
    t.index ["scoreboard_id"], name: "index_schools_on_scoreboard_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "schools_manual_readings", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.date "month", null: false
    t.float "electricity"
    t.float "gas"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "month"], name: "index_schools_manual_readings_on_school_id_and_month", unique: true
    t.index ["school_id"], name: "index_schools_manual_readings_on_school_id"
  end

  create_table "scoreboards", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "academic_year_calendar_id"
    t.boolean "public", default: true
    t.datetime "mailchimp_fields_changed_at"
    t.index ["academic_year_calendar_id"], name: "index_scoreboards_on_academic_year_calendar_id"
  end

  create_table "secr_co2_equivalences", force: :cascade do |t|
    t.integer "year"
    t.float "electricity_co2e"
    t.float "electricity_co2e_co2"
    t.float "transmission_distribution_co2e"
    t.float "natural_gas_co2e"
    t.float "natural_gas_co2e_co2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_secr_co2_equivalences_on_year", unique: true
  end

  create_table "site_settings", force: :cascade do |t|
    t.boolean "message_for_no_contacts", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "management_priorities_dashboard_limit", default: 5
    t.integer "management_priorities_page_limit", default: 10
    t.boolean "message_for_no_pupil_accounts", default: true
    t.jsonb "temperature_recording_months", default: ["10", "11", "12", "1", "2", "3", "4"]
    t.integer "default_import_warning_days", default: 10
    t.jsonb "prices"
    t.integer "photo_bonus_points", default: 0
    t.integer "audit_activities_bonus_points", default: 0
  end

  create_table "sms_records", force: :cascade do |t|
    t.bigint "alert_subscription_event_id"
    t.text "mobile_phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_subscription_event_id"], name: "index_sms_records_on_alert_subscription_event_id"
  end

  create_table "solar_edge_installations", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "amr_data_feed_config_id", null: false
    t.text "site_id"
    t.text "api_key"
    t.text "mpan"
    t.json "information", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id", "reading_date"], name: "index_solar_pv_tuos_readings_on_area_id_and_reading_date", unique: true
    t.index ["area_id"], name: "index_solar_pv_tuos_readings_on_area_id"
  end

  create_table "solis_cloud_installation_schools", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "solis_cloud_installation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_solis_cloud_installation_schools_on_school_id"
    t.index ["solis_cloud_installation_id"], name: "idx_on_solis_cloud_installation_id_c29f887970"
  end

  create_table "solis_cloud_installations", force: :cascade do |t|
    t.bigint "amr_data_feed_config_id", null: false
    t.text "api_id"
    t.text "api_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "inverter_detail_list", default: {}
    t.index ["amr_data_feed_config_id"], name: "index_solis_cloud_installations_on_amr_data_feed_config_id"
  end

  create_table "staff_roles", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "mailchimp_fields_changed_at"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "subscription_generation_runs", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_subscription_generation_runs_on_school_id"
  end

  create_table "tariff_import_logs", force: :cascade do |t|
    t.text "source", null: false
    t.text "description"
    t.text "error_messages"
    t.date "start_date"
    t.date "end_date"
    t.datetime "import_time", precision: nil
    t.integer "prices_imported", default: 0, null: false
    t.integer "prices_updated", default: 0, null: false
    t.integer "standing_charges_imported", default: 0, null: false
    t.integer "standing_charges_updated", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "team_members", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
  end

  create_table "temperature_recordings", force: :cascade do |t|
    t.bigint "observation_id", null: false
    t.bigint "location_id", null: false
    t.decimal "centigrade", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_temperature_recordings_on_location_id"
    t.index ["observation_id"], name: "index_temperature_recordings_on_observation_id"
  end

  create_table "testimonials", force: :cascade do |t|
    t.string "name"
    t.string "organisation"
    t.boolean "active", default: false, null: false
    t.integer "category", default: 0, null: false
    t.bigint "case_study_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_study_id"], name: "index_testimonials_on_case_study_id"
  end

  create_table "todos", force: :cascade do |t|
    t.string "assignable_type", null: false
    t.bigint "assignable_id", null: false
    t.string "task_type", null: false
    t.bigint "task_id", null: false
    t.integer "position", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignable_type", "assignable_id"], name: "index_todos_on_assignable"
    t.index ["task_type", "task_id"], name: "index_todos_on_task"
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "transifex_load_errors", force: :cascade do |t|
    t.string "record_type"
    t.bigint "record_id"
    t.string "error"
    t.bigint "transifex_load_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transifex_load_id"], name: "transifex_load_error_run_idx"
  end

  create_table "transifex_loads", force: :cascade do |t|
    t.integer "pushed", default: 0, null: false
    t.integer "pulled", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
  end

  create_table "transifex_statuses", force: :cascade do |t|
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "tx_last_push", precision: nil
    t.datetime "tx_last_pull", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_transifex_statuses_uniqueness", unique: true
  end

  create_table "transport_survey_responses", force: :cascade do |t|
    t.bigint "transport_survey_id", null: false
    t.bigint "transport_type_id", null: false
    t.integer "passengers", default: 1, null: false
    t.string "run_identifier", null: false
    t.datetime "surveyed_at", precision: nil, null: false
    t.integer "journey_minutes", default: 0, null: false
    t.integer "weather", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transport_survey_id"], name: "index_transport_survey_responses_on_transport_survey_id"
    t.index ["transport_type_id"], name: "index_transport_survey_responses_on_transport_type_id"
  end

  create_table "transport_surveys", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.date "run_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "park_and_stride", default: false, null: false
    t.integer "category"
    t.integer "position", default: 0, null: false
    t.index ["name"], name: "index_transport_types_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "school_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.bigint "staff_role_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.bigint "school_group_id"
    t.string "unlock_token"
    t.string "preferred_locale", default: "en", null: false
    t.string "pupil_password"
    t.bigint "created_by_id"
    t.datetime "mailchimp_fields_changed_at"
    t.datetime "mailchimp_updated_at"
    t.enum "mailchimp_status", enum_type: "mailchimp_status"
    t.boolean "active", default: true, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_group_id"], name: "index_users_on_school_group_id"
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["staff_role_id"], name: "index_users_on_staff_role_id"
  end

  create_table "videos", force: :cascade do |t|
    t.text "youtube_id", null: false
    t.text "title", null: false
    t.text "description"
    t.boolean "featured", default: true, null: false
    t.integer "position", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weather_observations", force: :cascade do |t|
    t.bigint "weather_station_id", null: false
    t.date "reading_date", null: false
    t.decimal "temperature_celsius_x48", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "back_fill_years", default: 4
  end

  add_foreign_key "academic_years", "calendars", on_delete: :restrict
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "activity_categories", on_delete: :restrict
  add_foreign_key "activities", "activity_types", on_delete: :restrict
  add_foreign_key "activities", "schools", on_delete: :cascade
  add_foreign_key "activities", "users", column: "updated_by_id"
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
  add_foreign_key "alert_errors", "comparison_reports"
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
  add_foreign_key "alerts", "comparison_reports"
  add_foreign_key "alerts", "schools", on_delete: :cascade
  add_foreign_key "amr_data_feed_configs", "users", column: "owned_by_id"
  add_foreign_key "amr_data_feed_readings", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "amr_data_feed_readings", "amr_data_feed_import_logs", on_delete: :cascade
  add_foreign_key "amr_data_feed_readings", "meters", on_delete: :nullify
  add_foreign_key "amr_reading_warnings", "amr_data_feed_import_logs", on_delete: :cascade
  add_foreign_key "amr_uploaded_readings", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "amr_validated_readings", "meters", on_delete: :cascade
  add_foreign_key "audits", "schools", on_delete: :cascade
  add_foreign_key "cads", "meters"
  add_foreign_key "cads", "schools", on_delete: :cascade
  add_foreign_key "calendar_events", "academic_years", on_delete: :restrict
  add_foreign_key "calendar_events", "calendar_event_types", on_delete: :restrict
  add_foreign_key "calendar_events", "calendars", on_delete: :cascade
  add_foreign_key "calendars", "calendars", column: "based_on_id", on_delete: :restrict
  add_foreign_key "case_studies", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "case_studies", "users", column: "updated_by_id", on_delete: :nullify
  add_foreign_key "cluster_schools_users", "schools", on_delete: :cascade
  add_foreign_key "cluster_schools_users", "users", on_delete: :cascade
  add_foreign_key "cms_categories", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "cms_categories", "users", column: "updated_by_id", on_delete: :nullify
  add_foreign_key "cms_pages", "cms_categories", column: "category_id"
  add_foreign_key "cms_pages", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "cms_pages", "users", column: "updated_by_id", on_delete: :nullify
  add_foreign_key "cms_sections", "cms_pages", column: "page_id"
  add_foreign_key "cms_sections", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "cms_sections", "users", column: "updated_by_id", on_delete: :nullify
  add_foreign_key "comparison_reports", "comparison_custom_periods", column: "custom_period_id"
  add_foreign_key "comparison_reports", "comparison_report_groups", column: "report_group_id"
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
  add_foreign_key "energy_tariffs", "users", column: "created_by_id"
  add_foreign_key "energy_tariffs", "users", column: "updated_by_id"
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
  add_foreign_key "meters", "solis_cloud_installations", on_delete: :cascade
  add_foreign_key "newsletters", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "newsletters", "users", column: "updated_by_id", on_delete: :nullify
  add_foreign_key "observations", "activities", on_delete: :nullify
  add_foreign_key "observations", "audits"
  add_foreign_key "observations", "intervention_types", on_delete: :restrict
  add_foreign_key "observations", "programmes", on_delete: :cascade
  add_foreign_key "observations", "school_targets"
  add_foreign_key "observations", "schools", on_delete: :cascade
  add_foreign_key "observations", "users", column: "created_by_id"
  add_foreign_key "observations", "users", column: "updated_by_id"
  add_foreign_key "programmes", "programme_types", on_delete: :cascade
  add_foreign_key "programmes", "schools", on_delete: :cascade
  add_foreign_key "resource_files", "resource_file_types", on_delete: :restrict
  add_foreign_key "rtone_variant_installations", "amr_data_feed_configs"
  add_foreign_key "rtone_variant_installations", "meters"
  add_foreign_key "rtone_variant_installations", "schools"
  add_foreign_key "school_alert_type_exclusions", "alert_types", on_delete: :cascade
  add_foreign_key "school_alert_type_exclusions", "schools", on_delete: :cascade
  add_foreign_key "school_alert_type_exclusions", "users", column: "created_by_id"
  add_foreign_key "school_batch_run_log_entries", "school_batch_runs", on_delete: :cascade
  add_foreign_key "school_batch_runs", "schools", on_delete: :cascade
  add_foreign_key "school_group_clusters", "school_groups", on_delete: :cascade
  add_foreign_key "school_group_meter_attributes", "school_group_meter_attributes", column: "replaced_by_id", on_delete: :nullify
  add_foreign_key "school_group_meter_attributes", "school_groups", on_delete: :cascade
  add_foreign_key "school_group_meter_attributes", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "school_group_meter_attributes", "users", column: "deleted_by_id", on_delete: :nullify
  add_foreign_key "school_groupings", "school_groups"
  add_foreign_key "school_groupings", "schools"
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
  add_foreign_key "school_onboardings", "calendars", column: "template_calendar_id", on_delete: :nullify
  add_foreign_key "school_onboardings", "school_groups", column: "project_group_id"
  add_foreign_key "school_onboardings", "school_groups", on_delete: :restrict
  add_foreign_key "school_onboardings", "schools", on_delete: :cascade
  add_foreign_key "school_onboardings", "scoreboards", on_delete: :nullify
  add_foreign_key "school_onboardings", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "school_onboardings", "users", column: "created_user_id", on_delete: :nullify
  add_foreign_key "school_target_events", "schools", on_delete: :cascade
  add_foreign_key "school_targets", "schools"
  add_foreign_key "school_times", "schools", on_delete: :cascade
  add_foreign_key "schools", "calendars", on_delete: :restrict
  add_foreign_key "schools", "school_group_clusters", on_delete: :nullify
  add_foreign_key "schools", "school_groups", on_delete: :restrict
  add_foreign_key "schools", "scoreboards", on_delete: :nullify
  add_foreign_key "schools_manual_readings", "schools", on_delete: :cascade
  add_foreign_key "scoreboards", "calendars", column: "academic_year_calendar_id", on_delete: :nullify
  add_foreign_key "sms_records", "alert_subscription_events", on_delete: :cascade
  add_foreign_key "solar_edge_installations", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "solar_edge_installations", "schools", on_delete: :cascade
  add_foreign_key "solar_pv_tuos_readings", "areas", on_delete: :cascade
  add_foreign_key "solis_cloud_installation_schools", "schools"
  add_foreign_key "solis_cloud_installation_schools", "solis_cloud_installations"
  add_foreign_key "solis_cloud_installations", "amr_data_feed_configs", on_delete: :cascade
  add_foreign_key "subscription_generation_runs", "schools", on_delete: :cascade
  add_foreign_key "temperature_recordings", "locations", on_delete: :cascade
  add_foreign_key "temperature_recordings", "observations", on_delete: :cascade
  add_foreign_key "transifex_load_errors", "transifex_loads"
  add_foreign_key "transport_survey_responses", "transport_surveys", on_delete: :cascade
  add_foreign_key "transport_survey_responses", "transport_types"
  add_foreign_key "transport_surveys", "schools", on_delete: :cascade
  add_foreign_key "users", "school_groups", on_delete: :restrict
  add_foreign_key "users", "schools", on_delete: :cascade
  add_foreign_key "users", "staff_roles", on_delete: :restrict
  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "weather_observations", "weather_stations", on_delete: :cascade

  create_view "comparison_annual_change_in_electricity_out_of_hours_uses", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      usage.alert_generation_run_id,
      usage.school_id,
      usage.out_of_hours_kwh,
      usage.out_of_hours_co2,
      usage.out_of_hours_gbpcurrent,
      usage_previous_year.previous_out_of_hours_kwh,
      usage_previous_year.previous_out_of_hours_co2,
      usage_previous_year.previous_out_of_hours_gbpcurrent,
      additional.economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.out_of_hours_kwh,
              json.out_of_hours_co2,
              json.out_of_hours_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(out_of_hours_kwh double precision, out_of_hours_co2 double precision, out_of_hours_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOutOfHoursElectricityUsage'::text))) usage,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.out_of_hours_kwh AS previous_out_of_hours_kwh,
              json.out_of_hours_co2 AS previous_out_of_hours_co2,
              json.out_of_hours_gbpcurrent AS previous_out_of_hours_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(out_of_hours_kwh double precision, out_of_hours_co2 double precision, out_of_hours_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOutOfHoursElectricityUsagePreviousYear'::text))) usage_previous_year,
      ( SELECT alerts.alert_generation_run_id,
              json.electricity_economic_tariff_changed_this_year AS economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((usage.alert_generation_run_id = latest_runs.id) AND (usage_previous_year.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_annual_change_in_electricity_out_of_hours_uses", ["school_id"], name: "idx_on_school_id_d6a1e1630d", unique: true

  create_view "comparison_annual_change_in_gas_out_of_hours_uses", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      usage.alert_generation_run_id,
      usage.school_id,
      usage.out_of_hours_kwh,
      usage.out_of_hours_co2,
      usage.out_of_hours_gbpcurrent,
      usage_previous_year.previous_out_of_hours_kwh,
      usage_previous_year.previous_out_of_hours_co2,
      usage_previous_year.previous_out_of_hours_gbpcurrent,
      additional.economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.out_of_hours_kwh,
              json.out_of_hours_co2,
              json.out_of_hours_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(out_of_hours_kwh double precision, out_of_hours_co2 double precision, out_of_hours_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOutOfHoursGasUsage'::text))) usage,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.out_of_hours_kwh AS previous_out_of_hours_kwh,
              json.out_of_hours_co2 AS previous_out_of_hours_co2,
              json.out_of_hours_gbpcurrent AS previous_out_of_hours_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(out_of_hours_kwh double precision, out_of_hours_co2 double precision, out_of_hours_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOutOfHoursGasUsagePreviousYear'::text))) usage_previous_year,
      ( SELECT alerts.alert_generation_run_id,
              json.gas_economic_tariff_changed_this_year AS economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(gas_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((usage.alert_generation_run_id = latest_runs.id) AND (usage_previous_year.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_annual_change_in_gas_out_of_hours_uses", ["school_id"], name: "idx_on_school_id_0e5d0539d9", unique: true

  create_view "comparison_annual_change_in_storage_heater_out_of_hours_uses", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      usage.alert_generation_run_id,
      usage.school_id,
      usage.out_of_hours_kwh,
      usage.out_of_hours_co2,
      usage.out_of_hours_gbpcurrent,
      usage_previous_year.previous_out_of_hours_kwh,
      usage_previous_year.previous_out_of_hours_co2,
      usage_previous_year.previous_out_of_hours_gbpcurrent,
      additional.economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.out_of_hours_kwh,
              json.out_of_hours_co2,
              json.out_of_hours_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(out_of_hours_kwh double precision, out_of_hours_co2 double precision, out_of_hours_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterOutOfHours'::text))) usage,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.out_of_hours_kwh AS previous_out_of_hours_kwh,
              json.out_of_hours_co2 AS previous_out_of_hours_co2,
              json.out_of_hours_gbpcurrent AS previous_out_of_hours_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(out_of_hours_kwh double precision, out_of_hours_co2 double precision, out_of_hours_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOutOfHoursStorageHeaterUsagePreviousYear'::text))) usage_previous_year,
      ( SELECT alerts.alert_generation_run_id,
              json.electricity_economic_tariff_changed_this_year AS economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((usage.alert_generation_run_id = latest_runs.id) AND (usage_previous_year.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_annual_change_in_storage_heater_out_of_hours_uses", ["school_id"], name: "idx_on_school_id_d34348aa11", unique: true

  create_view "comparison_annual_electricity_costs_per_pupils", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.one_year_electricity_per_pupil_gbp,
      data.one_year_electricity_per_pupil_kwh,
      data.one_year_electricity_per_pupil_co2,
      data.last_year_gbp,
      data.last_year_kwh,
      data.last_year_co2,
      data.one_year_saving_versus_exemplar_gbpcurrent,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.one_year_electricity_per_pupil_gbp,
              data_1.one_year_electricity_per_pupil_kwh,
              data_1.one_year_electricity_per_pupil_co2,
              data_1.last_year_gbp,
              data_1.last_year_kwh,
              data_1.last_year_co2,
              data_1.one_year_saving_versus_exemplar_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(one_year_electricity_per_pupil_gbp double precision, one_year_electricity_per_pupil_kwh double precision, one_year_electricity_per_pupil_co2 double precision, last_year_gbp double precision, last_year_kwh double precision, last_year_co2 double precision, one_year_saving_versus_exemplar_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertElectricityAnnualVersusBenchmark'::text))) data,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((data.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_annual_electricity_costs_per_pupils", ["school_id"], name: "idx_on_school_id_1d369f6529", unique: true

  create_view "comparison_annual_electricity_out_of_hours_uses", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.schoolday_open_percent,
      data.schoolday_closed_percent,
      data.holidays_percent,
      data.weekends_percent,
      data.community_percent,
      data.community_gbp,
      data.out_of_hours_gbp,
      data.potential_saving_gbp,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.schoolday_open_percent,
              data_1.schoolday_closed_percent,
              data_1.holidays_percent,
              data_1.weekends_percent,
              data_1.community_percent,
              data_1.community_gbp,
              data_1.out_of_hours_gbp,
              data_1.potential_saving_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(schoolday_open_percent double precision, schoolday_closed_percent double precision, holidays_percent double precision, weekends_percent double precision, community_percent double precision, community_gbp double precision, out_of_hours_gbp double precision, potential_saving_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOutOfHoursElectricityUsage'::text))) data,
      ( SELECT alerts.alert_generation_run_id,
              data_1.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((data.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_annual_electricity_out_of_hours_uses", ["school_id"], name: "idx_on_school_id_579efb1ff6", unique: true

  create_view "comparison_annual_energy_costs", materialized: true, sql_definition: <<-SQL
      WITH electricity AS (
           SELECT alerts.alert_generation_run_id,
              data.last_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertElectricityAnnualVersusBenchmark'::text))
          ), gas AS (
           SELECT alerts.alert_generation_run_id,
              data.last_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertGasAnnualVersusBenchmark'::text))
          ), storage_heaters AS (
           SELECT alerts.alert_generation_run_id,
              data.last_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterAnnualVersusBenchmark'::text))
          ), energy AS (
           SELECT alerts.alert_generation_run_id,
              data.last_year_gbp,
              data.one_year_energy_per_pupil_gbp,
              data.last_year_co2_tonnes,
              data.last_year_kwh
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_gbp double precision, one_year_energy_per_pupil_gbp double precision, last_year_co2_tonnes double precision, last_year_kwh double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.school_type_name,
              data.pupils,
              data.floor_area
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(school_type_name text, pupils double precision, floor_area double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      electricity.last_year_gbp AS last_year_electricity,
      gas.last_year_gbp AS last_year_gas,
      storage_heaters.last_year_gbp AS last_year_storage_heaters,
      energy.last_year_gbp,
      energy.one_year_energy_per_pupil_gbp,
      energy.last_year_co2_tonnes,
      energy.last_year_kwh,
      additional.alert_generation_run_id,
      additional.school_id,
      additional.school_type_name,
      additional.pupils,
      additional.floor_area
     FROM (((((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN electricity ON ((latest_runs.id = electricity.alert_generation_run_id)))
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)))
       LEFT JOIN storage_heaters ON ((latest_runs.id = storage_heaters.alert_generation_run_id)))
       LEFT JOIN energy ON ((latest_runs.id = energy.alert_generation_run_id)));
  SQL
  add_index "comparison_annual_energy_costs", ["school_id"], name: "index_comparison_annual_energy_costs_on_school_id", unique: true

  create_view "comparison_annual_energy_costs_per_units", materialized: true, sql_definition: <<-SQL
      WITH electricity AS (
           SELECT alerts.alert_generation_run_id,
              data.one_year_electricity_per_pupil_kwh,
              data.one_year_electricity_per_pupil_gbp,
              data.one_year_electricity_per_pupil_co2,
              data.one_year_electricity_per_floor_area_kwh,
              data.one_year_electricity_per_floor_area_gbp,
              data.one_year_electricity_per_floor_area_co2
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(one_year_electricity_per_pupil_kwh double precision, one_year_electricity_per_pupil_gbp double precision, one_year_electricity_per_pupil_co2 double precision, one_year_electricity_per_floor_area_kwh double precision, one_year_electricity_per_floor_area_gbp double precision, one_year_electricity_per_floor_area_co2 double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertElectricityAnnualVersusBenchmark'::text))
          ), gas AS (
           SELECT alerts.alert_generation_run_id,
              data.one_year_gas_per_pupil_kwh,
              data.one_year_gas_per_pupil_gbp,
              data.one_year_gas_per_pupil_co2,
              data.one_year_gas_per_floor_area_kwh,
              data.one_year_gas_per_floor_area_gbp,
              data.one_year_gas_per_floor_area_co2
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(one_year_gas_per_pupil_kwh double precision, one_year_gas_per_pupil_gbp double precision, one_year_gas_per_pupil_co2 double precision, one_year_gas_per_floor_area_kwh double precision, one_year_gas_per_floor_area_gbp double precision, one_year_gas_per_floor_area_co2 double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertGasAnnualVersusBenchmark'::text))
          ), storage_heaters AS (
           SELECT alerts.alert_generation_run_id,
              data.one_year_gas_per_pupil_kwh,
              data.one_year_gas_per_pupil_gbp,
              data.one_year_gas_per_pupil_co2,
              data.one_year_gas_per_floor_area_kwh,
              data.one_year_gas_per_floor_area_gbp,
              data.one_year_gas_per_floor_area_co2
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(one_year_gas_per_pupil_kwh double precision, one_year_gas_per_pupil_gbp double precision, one_year_gas_per_pupil_co2 double precision, one_year_gas_per_floor_area_kwh double precision, one_year_gas_per_floor_area_gbp double precision, one_year_gas_per_floor_area_co2 double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterAnnualVersusBenchmark'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.electricity_economic_tariff_changed_this_year,
              data.gas_economic_tariff_changed_this_year,
              data.pupils,
              data.floor_area
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(electricity_economic_tariff_changed_this_year boolean, gas_economic_tariff_changed_this_year boolean, pupils double precision, floor_area double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      electricity.one_year_electricity_per_pupil_kwh,
      electricity.one_year_electricity_per_pupil_gbp,
      electricity.one_year_electricity_per_pupil_co2,
      electricity.one_year_electricity_per_floor_area_kwh,
      electricity.one_year_electricity_per_floor_area_gbp,
      electricity.one_year_electricity_per_floor_area_co2,
      gas.one_year_gas_per_pupil_kwh,
      gas.one_year_gas_per_pupil_gbp,
      gas.one_year_gas_per_pupil_co2,
      gas.one_year_gas_per_floor_area_kwh,
      gas.one_year_gas_per_floor_area_gbp,
      gas.one_year_gas_per_floor_area_co2,
      storage_heaters.one_year_gas_per_pupil_kwh AS one_year_storage_heater_per_pupil_kwh,
      storage_heaters.one_year_gas_per_pupil_gbp AS one_year_storage_heater_per_pupil_gbp,
      storage_heaters.one_year_gas_per_pupil_co2 AS one_year_storage_heater_per_pupil_co2,
      storage_heaters.one_year_gas_per_floor_area_kwh AS one_year_storage_heater_per_floor_area_kwh,
      storage_heaters.one_year_gas_per_floor_area_gbp AS one_year_storage_heater_per_floor_area_gbp,
      storage_heaters.one_year_gas_per_floor_area_co2 AS one_year_storage_heater_per_floor_area_co2,
      additional.school_id,
      additional.electricity_economic_tariff_changed_this_year,
      additional.gas_economic_tariff_changed_this_year,
      additional.pupils,
      additional.floor_area
     FROM ((((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN electricity ON ((latest_runs.id = electricity.alert_generation_run_id)))
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)))
       LEFT JOIN storage_heaters ON ((latest_runs.id = storage_heaters.alert_generation_run_id)));
  SQL
  add_index "comparison_annual_energy_costs_per_units", ["school_id"], name: "index_comparison_annual_energy_costs_per_units_on_school_id", unique: true

  create_view "comparison_annual_energy_uses", materialized: true, sql_definition: <<-SQL
      WITH electricity AS (
           SELECT alerts.alert_generation_run_id,
              data.last_year_kwh,
              data.last_year_co2,
              data.last_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_kwh double precision, last_year_co2 double precision, last_year_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertElectricityAnnualVersusBenchmark'::text))
          ), gas AS (
           SELECT alerts.alert_generation_run_id,
              data.last_year_kwh,
              data.last_year_co2,
              data.last_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_kwh double precision, last_year_co2 double precision, last_year_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertGasAnnualVersusBenchmark'::text))
          ), storage_heaters AS (
           SELECT alerts.alert_generation_run_id,
              data.last_year_kwh,
              data.last_year_co2,
              data.last_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_kwh double precision, last_year_co2 double precision, last_year_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterAnnualVersusBenchmark'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.electricity_economic_tariff_changed_this_year,
              data.gas_economic_tariff_changed_this_year,
              data.school_type_name,
              data.pupils,
              data.floor_area
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(electricity_economic_tariff_changed_this_year boolean, gas_economic_tariff_changed_this_year boolean, school_type_name text, pupils double precision, floor_area double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      electricity.last_year_kwh AS electricity_last_year_kwh,
      electricity.last_year_gbp AS electricity_last_year_gbp,
      electricity.last_year_co2 AS electricity_last_year_co2,
      gas.last_year_kwh AS gas_last_year_kwh,
      gas.last_year_gbp AS gas_last_year_gbp,
      gas.last_year_co2 AS gas_last_year_co2,
      storage_heaters.last_year_kwh AS storage_heaters_last_year_kwh,
      storage_heaters.last_year_gbp AS storage_heaters_last_year_gbp,
      storage_heaters.last_year_co2 AS storage_heaters_last_year_co2,
      additional.electricity_economic_tariff_changed_this_year AS electricity_tariff_has_changed,
      additional.gas_economic_tariff_changed_this_year AS gas_tariff_has_changed,
      additional.school_type_name,
      additional.pupils,
      additional.floor_area,
      additional.school_id,
      additional.alert_generation_run_id
     FROM ((((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN electricity ON ((latest_runs.id = electricity.alert_generation_run_id)))
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)))
       LEFT JOIN storage_heaters ON ((latest_runs.id = storage_heaters.alert_generation_run_id)));
  SQL
  add_index "comparison_annual_energy_uses", ["school_id"], name: "index_comparison_annual_energy_uses_on_school_id", unique: true

  create_view "comparison_annual_gas_out_of_hours_uses", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.schoolday_open_percent,
      data.schoolday_closed_percent,
      data.holidays_percent,
      data.weekends_percent,
      data.community_percent,
      data.community_gbp,
      data.out_of_hours_gbp,
      data.potential_saving_gbp,
      additional.gas_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.schoolday_open_percent,
              data_1.schoolday_closed_percent,
              data_1.holidays_percent,
              data_1.weekends_percent,
              data_1.community_percent,
              data_1.community_gbp,
              data_1.out_of_hours_gbp,
              data_1.potential_saving_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(schoolday_open_percent double precision, schoolday_closed_percent double precision, holidays_percent double precision, weekends_percent double precision, community_percent double precision, community_gbp double precision, out_of_hours_gbp double precision, potential_saving_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOutOfHoursGasUsage'::text))) data,
      ( SELECT alerts.alert_generation_run_id,
              data_1.gas_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(gas_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((data.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_annual_gas_out_of_hours_uses", ["school_id"], name: "index_comparison_annual_gas_out_of_hours_uses_on_school_id", unique: true

  create_view "comparison_annual_heating_costs_per_floor_areas", materialized: true, sql_definition: <<-SQL
      WITH gas AS (
           SELECT alerts.alert_generation_run_id,
              data.one_year_gas_per_floor_area_gbp,
              data.one_year_gas_per_floor_area_kwh,
              data.one_year_gas_per_floor_area_co2,
              data.last_year_gbp,
              data.last_year_kwh,
              data.last_year_co2,
              data.one_year_saving_versus_exemplar_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(one_year_gas_per_floor_area_gbp double precision, one_year_gas_per_floor_area_kwh double precision, one_year_gas_per_floor_area_co2 double precision, last_year_gbp double precision, last_year_kwh double precision, last_year_co2 double precision, one_year_saving_versus_exemplar_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertGasAnnualVersusBenchmark'::text))
          ), storage_heaters AS (
           SELECT alerts.alert_generation_run_id,
              data.one_year_gas_per_floor_area_gbp,
              data.one_year_gas_per_floor_area_kwh,
              data.one_year_gas_per_floor_area_co2,
              data.last_year_gbp,
              data.last_year_kwh,
              data.last_year_co2,
              data.one_year_saving_versus_exemplar_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(one_year_gas_per_floor_area_gbp double precision, one_year_gas_per_floor_area_kwh double precision, one_year_gas_per_floor_area_co2 double precision, last_year_gbp double precision, last_year_kwh double precision, last_year_co2 double precision, one_year_saving_versus_exemplar_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterAnnualVersusBenchmark'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.gas_economic_tariff_changed_this_year,
              data.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(gas_economic_tariff_changed_this_year boolean, electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      additional.school_id,
      gas.last_year_gbp AS gas_last_year_gbp,
      gas.last_year_kwh AS gas_last_year_kwh,
      gas.last_year_co2 AS gas_last_year_co2,
      gas.one_year_gas_per_floor_area_gbp,
      gas.one_year_gas_per_floor_area_kwh,
      gas.one_year_gas_per_floor_area_co2,
      storage_heaters.last_year_gbp AS storage_heaters_last_year_gbp,
      storage_heaters.last_year_kwh AS storage_heaters_last_year_kwh,
      storage_heaters.last_year_co2 AS storage_heaters_last_year_co2,
      storage_heaters.one_year_gas_per_floor_area_gbp AS one_year_storage_heaters_per_floor_area_gbp,
      storage_heaters.one_year_gas_per_floor_area_kwh AS one_year_storage_heaters_per_floor_area_kwh,
      storage_heaters.one_year_gas_per_floor_area_co2 AS one_year_storage_heaters_per_floor_area_co2,
      gas.one_year_saving_versus_exemplar_gbpcurrent AS one_year_gas_saving_versus_exemplar_gbpcurrent,
      storage_heaters.one_year_saving_versus_exemplar_gbpcurrent AS one_year_storage_heaters_saving_versus_exemplar_gbpcurrent,
      additional.gas_economic_tariff_changed_this_year,
      additional.electricity_economic_tariff_changed_this_year
     FROM (((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)))
       LEFT JOIN storage_heaters ON ((latest_runs.id = storage_heaters.alert_generation_run_id)));
  SQL
  add_index "comparison_annual_heating_costs_per_floor_areas", ["school_id"], name: "idx_on_school_id_80be77e6f6", unique: true

  create_view "comparison_annual_storage_heater_out_of_hours_uses", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.schoolday_open_percent,
      data.schoolday_closed_percent,
      data.holidays_percent,
      data.weekends_percent,
      data.holidays_gbp,
      data.weekends_gbp
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.schoolday_open_percent,
              data_1.schoolday_closed_percent,
              data_1.holidays_percent,
              data_1.weekends_percent,
              data_1.holidays_gbp,
              data_1.weekends_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(schoolday_open_percent double precision, schoolday_closed_percent double precision, holidays_percent double precision, weekends_percent double precision, holidays_gbp double precision, weekends_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterOutOfHours'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_annual_storage_heater_out_of_hours_uses", ["school_id"], name: "idx_on_school_id_9addfaf1f6", unique: true

  create_view "comparison_baseload_per_pupils", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      additional.school_id,
      baseload.alert_generation_run_id,
      baseload.average_baseload_last_year_kw,
      baseload.average_baseload_last_year_gbp,
      baseload.one_year_baseload_per_pupil_kw,
      baseload.annual_baseload_percent,
      baseload.one_year_saving_versus_exemplar_gbp,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              data.average_baseload_last_year_kw,
              data.average_baseload_last_year_gbp,
              data.one_year_baseload_per_pupil_kw,
              data.annual_baseload_percent,
              data.one_year_saving_versus_exemplar_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(average_baseload_last_year_kw double precision, average_baseload_last_year_gbp double precision, one_year_baseload_per_pupil_kw double precision, annual_baseload_percent double precision, one_year_saving_versus_exemplar_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertElectricityBaseloadVersusBenchmark'::text))) baseload,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((baseload.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_baseload_per_pupils", ["school_id"], name: "index_comparison_baseload_per_pupils_on_school_id", unique: true

  create_view "comparison_change_in_electricity_holiday_consumption_previous_h", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.difference_percent,
      data.difference_gbpcurrent,
      data.difference_kwh,
      data.current_period_type,
      data.current_period_start_date,
      data.current_period_end_date,
      data.truncated_current_period,
      data.previous_period_type,
      data.previous_period_start_date,
      data.previous_period_end_date,
      data.pupils_changed,
      data.tariff_has_changed
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.difference_percent,
              data_1.difference_gbpcurrent,
              data_1.difference_kwh,
              data_1.current_period_type,
              data_1.current_period_start_date,
              data_1.current_period_end_date,
              data_1.truncated_current_period,
              data_1.previous_period_type,
              data_1.previous_period_start_date,
              data_1.previous_period_end_date,
              data_1.pupils_changed,
              data_1.tariff_has_changed
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(difference_percent double precision, difference_gbpcurrent double precision, difference_kwh double precision, current_period_type text, current_period_start_date date, current_period_end_date date, truncated_current_period boolean, previous_period_type text, previous_period_start_date date, previous_period_end_date date, pupils_changed boolean, tariff_has_changed boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertPreviousHolidayComparisonElectricity'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_change_in_electricity_holiday_consumption_previous_h", ["school_id"], name: "idx_on_school_id_8c3fc8440e", unique: true

  create_view "comparison_change_in_electricity_holiday_consumption_previous_y", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.current_period_type,
      data.current_period_start_date,
      data.current_period_end_date,
      data.difference_gbpcurrent,
      data.difference_kwh,
      data.difference_percent,
      data.previous_period_type,
      data.previous_period_start_date,
      data.previous_period_end_date,
      data.pupils_changed,
      data.tariff_has_changed,
      data.truncated_current_period
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.current_period_type,
              data_1.current_period_start_date,
              data_1.current_period_end_date,
              data_1.difference_gbpcurrent,
              data_1.difference_kwh,
              data_1.difference_percent,
              data_1.previous_period_type,
              data_1.previous_period_start_date,
              data_1.previous_period_end_date,
              data_1.pupils_changed,
              data_1.tariff_has_changed,
              data_1.truncated_current_period
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(current_period_type text, current_period_start_date date, current_period_end_date date, difference_gbpcurrent double precision, difference_kwh double precision, difference_percent double precision, previous_period_type text, previous_period_start_date date, previous_period_end_date date, pupils_changed boolean, tariff_has_changed boolean, truncated_current_period boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertPreviousYearHolidayComparisonElectricity'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_change_in_electricity_holiday_consumption_previous_y", ["school_id"], name: "idx_on_school_id_dd11f128c1", unique: true

  create_view "comparison_change_in_electricity_since_last_years", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      enba.school_id,
      enba.previous_year_electricity_kwh,
      enba.current_year_electricity_kwh,
      enba.previous_year_electricity_co2,
      enba.current_year_electricity_co2,
      enba.previous_year_electricity_gbp,
      enba.current_year_electricity_gbp,
      enba.solar_type
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.previous_year_electricity_kwh,
              data.current_year_electricity_kwh,
              data.previous_year_electricity_co2,
              data.current_year_electricity_co2,
              data.previous_year_electricity_gbp,
              data.current_year_electricity_gbp,
              data.solar_type
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(previous_year_electricity_kwh double precision, current_year_electricity_kwh double precision, previous_year_electricity_co2 double precision, current_year_electricity_co2 double precision, previous_year_electricity_gbp double precision, current_year_electricity_gbp double precision, solar_type text)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))) enba,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (enba.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_change_in_electricity_since_last_years", ["school_id"], name: "idx_on_school_id_14ce133c88", unique: true

  create_view "comparison_change_in_energy_since_last_years", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      energy.school_id,
      energy.current_year_electricity_kwh AS electricity_current_period_kwh,
      energy.previous_year_electricity_kwh AS electricity_previous_period_kwh,
      energy.current_year_electricity_co2 AS electricity_current_period_co2,
      energy.previous_year_electricity_co2 AS electricity_previous_period_co2,
      energy.current_year_electricity_gbp AS electricity_current_period_gbp,
      energy.previous_year_electricity_gbp AS electricity_previous_period_gbp,
      energy.current_year_gas_kwh AS gas_current_period_kwh,
      energy.previous_year_gas_kwh AS gas_previous_period_kwh,
      energy.current_year_gas_co2 AS gas_current_period_co2,
      energy.previous_year_gas_co2 AS gas_previous_period_co2,
      energy.current_year_gas_gbp AS gas_current_period_gbp,
      energy.previous_year_gas_gbp AS gas_previous_period_gbp,
      energy.current_year_storage_heaters_kwh AS storage_heater_current_period_kwh,
      energy.previous_year_storage_heaters_kwh AS storage_heater_previous_period_kwh,
      energy.current_year_storage_heaters_co2 AS storage_heater_current_period_co2,
      energy.previous_year_storage_heaters_co2 AS storage_heater_previous_period_co2,
      energy.current_year_storage_heaters_gbp AS storage_heater_current_period_gbp,
      energy.previous_year_storage_heaters_gbp AS storage_heater_previous_period_gbp,
      energy.current_year_solar_pv_kwh AS solar_pv_current_period_kwh,
      energy.previous_year_solar_pv_kwh AS solar_pv_previous_period_kwh,
      energy.current_year_solar_pv_co2 AS solar_pv_current_period_co2,
      energy.previous_year_solar_pv_co2 AS solar_pv_previous_period_co2,
      additional.electricity_economic_tariff_changed_this_year AS electricity_tariff_has_changed,
      additional.gas_economic_tariff_changed_this_year AS gas_tariff_has_changed,
      energy.solar_type
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.previous_year_electricity_kwh,
              data.current_year_electricity_kwh,
              data.previous_year_electricity_co2,
              data.current_year_electricity_co2,
              data.previous_year_electricity_gbp,
              data.current_year_electricity_gbp,
              data.previous_year_gas_kwh,
              data.current_year_gas_kwh,
              data.previous_year_gas_co2,
              data.current_year_gas_co2,
              data.previous_year_gas_gbp,
              data.current_year_gas_gbp,
              data.previous_year_storage_heaters_kwh,
              data.current_year_storage_heaters_kwh,
              data.previous_year_storage_heaters_co2,
              data.current_year_storage_heaters_co2,
              data.previous_year_storage_heaters_gbp,
              data.current_year_storage_heaters_gbp,
              data.previous_year_solar_pv_kwh,
              data.current_year_solar_pv_kwh,
              data.previous_year_solar_pv_co2,
              data.current_year_solar_pv_co2,
              data.solar_type
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(previous_year_electricity_kwh double precision, current_year_electricity_kwh double precision, previous_year_electricity_co2 double precision, current_year_electricity_co2 double precision, previous_year_electricity_gbp double precision, current_year_electricity_gbp double precision, previous_year_gas_kwh double precision, current_year_gas_kwh double precision, previous_year_gas_co2 double precision, current_year_gas_co2 double precision, previous_year_gas_gbp double precision, current_year_gas_gbp double precision, previous_year_storage_heaters_kwh double precision, current_year_storage_heaters_kwh double precision, previous_year_storage_heaters_co2 double precision, current_year_storage_heaters_co2 double precision, previous_year_storage_heaters_gbp double precision, current_year_storage_heaters_gbp double precision, previous_year_solar_pv_kwh double precision, current_year_solar_pv_kwh double precision, previous_year_solar_pv_co2 double precision, current_year_solar_pv_co2 double precision, solar_type text)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))) energy,
      ( SELECT alerts.alert_generation_run_id,
              data.electricity_economic_tariff_changed_this_year,
              data.gas_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(electricity_economic_tariff_changed_this_year boolean, gas_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((energy.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_change_in_energy_since_last_years", ["school_id"], name: "idx_on_school_id_ef404854ff", unique: true

  create_view "comparison_change_in_energy_use_since_joined_energy_sparks", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      energy.school_id,
      additional.activation_date,
      energy.current_year_electricity_kwh AS electricity_current_period_kwh,
      energy.activationyear_electricity_kwh AS electricity_previous_period_kwh,
      energy.current_year_electricity_co2 AS electricity_current_period_co2,
      energy.activationyear_electricity_co2 AS electricity_previous_period_co2,
      energy.current_year_electricity_gbp AS electricity_current_period_gbp,
      energy.activationyear_electricity_gbp AS electricity_previous_period_gbp,
      energy.current_year_gas_kwh AS gas_current_period_kwh,
      energy.activationyear_gas_kwh AS gas_previous_period_kwh,
      energy.current_year_gas_co2 AS gas_current_period_co2,
      energy.activationyear_gas_co2 AS gas_previous_period_co2,
      energy.current_year_gas_gbp AS gas_current_period_gbp,
      energy.activationyear_gas_gbp AS gas_previous_period_gbp,
      energy.current_year_storage_heaters_kwh AS storage_heater_current_period_kwh,
      energy.activationyear_storage_heaters_kwh AS storage_heater_previous_period_kwh,
      energy.current_year_storage_heaters_co2 AS storage_heater_current_period_co2,
      energy.activationyear_storage_heaters_co2 AS storage_heater_previous_period_co2,
      energy.current_year_storage_heaters_gbp AS storage_heater_current_period_gbp,
      energy.activationyear_storage_heaters_gbp AS storage_heater_previous_period_gbp,
      energy.activationyear_electricity_kwh_relative_percent AS activationyear_electricity_note,
      energy.activationyear_gas_kwh_relative_percent AS activationyear_gas_note,
      energy.activationyear_storage_heaters_kwh_relative_percent AS activationyear_storage_heater_note,
      energy.solar_type
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.activationyear_electricity_kwh,
              data.current_year_electricity_kwh,
              data.activationyear_electricity_co2,
              data.current_year_electricity_co2,
              data.activationyear_electricity_gbp,
              data.current_year_electricity_gbp,
              data.activationyear_gas_kwh,
              data.current_year_gas_kwh,
              data.activationyear_gas_co2,
              data.current_year_gas_co2,
              data.activationyear_gas_gbp,
              data.current_year_gas_gbp,
              data.activationyear_storage_heaters_kwh,
              data.current_year_storage_heaters_kwh,
              data.activationyear_storage_heaters_co2,
              data.current_year_storage_heaters_co2,
              data.activationyear_storage_heaters_gbp,
              data.current_year_storage_heaters_gbp,
              data.activationyear_electricity_kwh_relative_percent,
              data.activationyear_gas_kwh_relative_percent,
              data.activationyear_storage_heaters_kwh_relative_percent,
              data.solar_type
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(activationyear_electricity_kwh double precision, current_year_electricity_kwh double precision, activationyear_electricity_co2 double precision, current_year_electricity_co2 double precision, activationyear_electricity_gbp double precision, current_year_electricity_gbp double precision, activationyear_gas_kwh double precision, current_year_gas_kwh double precision, activationyear_gas_co2 double precision, current_year_gas_co2 double precision, activationyear_gas_gbp double precision, current_year_gas_gbp double precision, activationyear_storage_heaters_kwh double precision, current_year_storage_heaters_kwh double precision, activationyear_storage_heaters_co2 double precision, current_year_storage_heaters_co2 double precision, activationyear_storage_heaters_gbp double precision, current_year_storage_heaters_gbp double precision, activationyear_electricity_kwh_relative_percent text, activationyear_gas_kwh_relative_percent text, activationyear_storage_heaters_kwh_relative_percent text, solar_type text)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))) energy,
      ( SELECT alerts.alert_generation_run_id,
              data.activation_date
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(activation_date date)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((energy.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_change_in_energy_use_since_joined_energy_sparks", ["school_id"], name: "idx_on_school_id_f606257469", unique: true

  create_view "comparison_change_in_gas_holiday_consumption_previous_holidays", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.difference_percent,
      data.difference_gbpcurrent,
      data.difference_kwh,
      data.current_period_type,
      data.current_period_start_date,
      data.current_period_end_date,
      data.truncated_current_period,
      data.previous_period_type,
      data.previous_period_start_date,
      data.previous_period_end_date,
      data.pupils_changed,
      data.tariff_has_changed
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.difference_percent,
              data_1.difference_gbpcurrent,
              data_1.difference_kwh,
              data_1.current_period_type,
              data_1.current_period_start_date,
              data_1.current_period_end_date,
              data_1.truncated_current_period,
              data_1.previous_period_type,
              data_1.previous_period_start_date,
              data_1.previous_period_end_date,
              data_1.pupils_changed,
              data_1.tariff_has_changed
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(difference_percent double precision, difference_gbpcurrent double precision, difference_kwh double precision, current_period_type text, current_period_start_date date, current_period_end_date date, truncated_current_period boolean, previous_period_type text, previous_period_start_date date, previous_period_end_date date, pupils_changed boolean, tariff_has_changed boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertPreviousHolidayComparisonGas'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_change_in_gas_holiday_consumption_previous_holidays", ["school_id"], name: "idx_on_school_id_f6702c3aa6", unique: true

  create_view "comparison_change_in_gas_holiday_consumption_previous_years_hol", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.difference_percent,
      data.difference_gbpcurrent,
      data.difference_kwh,
      data.current_period_type,
      data.current_period_start_date,
      data.current_period_end_date,
      data.truncated_current_period,
      data.previous_period_type,
      data.previous_period_start_date,
      data.previous_period_end_date,
      data.pupils_changed,
      data.tariff_has_changed
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.difference_percent,
              data_1.difference_gbpcurrent,
              data_1.difference_kwh,
              data_1.current_period_type,
              data_1.current_period_start_date,
              data_1.current_period_end_date,
              data_1.truncated_current_period,
              data_1.previous_period_type,
              data_1.previous_period_start_date,
              data_1.previous_period_end_date,
              data_1.pupils_changed,
              data_1.tariff_has_changed
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(difference_percent double precision, difference_gbpcurrent double precision, difference_kwh double precision, current_period_type text, current_period_start_date date, current_period_end_date date, truncated_current_period boolean, previous_period_type text, previous_period_start_date date, previous_period_end_date date, pupils_changed boolean, tariff_has_changed boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertPreviousYearHolidayComparisonGas'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_change_in_gas_holiday_consumption_previous_years_hol", ["school_id"], name: "idx_on_school_id_a2d5e09d4c", unique: true

  create_view "comparison_change_in_gas_since_last_years", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      energy.alert_generation_run_id,
      energy.school_id,
      energy.previous_year_kwh,
      energy.current_year_kwh,
      energy.previous_year_co2,
      energy.current_year_co2,
      energy.previous_year_gbp,
      energy.current_year_gbp,
      gas.temperature_adjusted_previous_year_kwh,
      gas.temperature_adjusted_percent
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.previous_year_gas_kwh AS previous_year_kwh,
              json.current_year_gas_kwh AS current_year_kwh,
              json.previous_year_gas_co2 AS previous_year_co2,
              json.current_year_gas_co2 AS current_year_co2,
              json.previous_year_gas_gbp AS previous_year_gbp,
              json.current_year_gas_gbp AS current_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(previous_year_gas_kwh double precision, current_year_gas_kwh double precision, previous_year_gas_co2 double precision, current_year_gas_co2 double precision, previous_year_gas_gbp double precision, current_year_gas_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))) energy,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.temperature_adjusted_previous_year_kwh,
              json.temperature_adjusted_percent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(temperature_adjusted_previous_year_kwh double precision, temperature_adjusted_percent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertGasAnnualVersusBenchmark'::text))) gas,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((energy.alert_generation_run_id = latest_runs.id) AND (gas.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_change_in_gas_since_last_years", ["school_id"], name: "index_comparison_change_in_gas_since_last_years_on_school_id", unique: true

  create_view "comparison_change_in_solar_pv_since_last_years", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      versus_benchmark.school_id,
      versus_benchmark.previous_year_solar_pv_kwh,
      versus_benchmark.current_year_solar_pv_kwh,
      versus_benchmark.previous_year_solar_pv_co2,
      versus_benchmark.current_year_solar_pv_co2,
      versus_benchmark.solar_type
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.previous_year_solar_pv_kwh,
              data.current_year_solar_pv_kwh,
              data.previous_year_solar_pv_co2,
              data.current_year_solar_pv_co2,
              data.solar_type
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(previous_year_solar_pv_kwh double precision, current_year_solar_pv_kwh double precision, previous_year_solar_pv_co2 double precision, current_year_solar_pv_co2 double precision, solar_type text)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))) versus_benchmark,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (versus_benchmark.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_change_in_solar_pv_since_last_years", ["school_id"], name: "idx_on_school_id_d981c52c1c", unique: true

  create_view "comparison_change_in_storage_heaters_since_last_years", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      energy.alert_generation_run_id,
      energy.school_id,
      energy.previous_year_kwh,
      energy.current_year_kwh,
      energy.previous_year_co2,
      energy.current_year_co2,
      energy.previous_year_gbp,
      energy.current_year_gbp,
      storage.temperature_adjusted_previous_year_kwh,
      storage.temperature_adjusted_percent
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.previous_year_storage_heaters_kwh AS previous_year_kwh,
              json.current_year_storage_heaters_kwh AS current_year_kwh,
              json.previous_year_storage_heaters_co2 AS previous_year_co2,
              json.current_year_storage_heaters_co2 AS current_year_co2,
              json.previous_year_storage_heaters_gbp AS previous_year_gbp,
              json.current_year_storage_heaters_gbp AS current_year_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(previous_year_storage_heaters_kwh double precision, current_year_storage_heaters_kwh double precision, previous_year_storage_heaters_co2 double precision, current_year_storage_heaters_co2 double precision, previous_year_storage_heaters_gbp double precision, current_year_storage_heaters_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))) energy,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.temperature_adjusted_previous_year_kwh,
              json.temperature_adjusted_percent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(temperature_adjusted_previous_year_kwh double precision, temperature_adjusted_percent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterAnnualVersusBenchmark'::text))) storage,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((energy.alert_generation_run_id = latest_runs.id) AND (storage.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_change_in_storage_heaters_since_last_years", ["school_id"], name: "idx_on_school_id_5808ed6062", unique: true

  create_view "comparison_configurable_periods", materialized: true, sql_definition: <<-SQL
      WITH electricity AS (
           SELECT alerts.alert_generation_run_id,
              alerts.comparison_report_id,
              json.current_period_kwh,
              json.previous_period_kwh,
              json.current_period_co2,
              json.previous_period_co2,
              json.current_period_gbp,
              json.previous_period_gbp,
              json.tariff_has_changed,
              json.pupils_changed,
              json.floor_area_changed
             FROM (alerts
               JOIN alert_types ON ((alerts.alert_type_id = alert_types.id))),
              LATERAL jsonb_to_record(alerts.variables) json(current_period_kwh double precision, previous_period_kwh double precision, current_period_co2 double precision, previous_period_co2 double precision, current_period_gbp double precision, previous_period_gbp double precision, tariff_has_changed boolean, pupils_changed boolean, floor_area_changed boolean)
            WHERE (alert_types.class_name = 'AlertConfigurablePeriodElectricityComparison'::text)
          ), gas AS (
           SELECT alerts.alert_generation_run_id,
              alerts.comparison_report_id,
              json.current_period_kwh,
              json.previous_period_kwh,
              json.current_period_co2,
              json.previous_period_co2,
              json.current_period_gbp,
              json.previous_period_gbp,
              json.previous_period_kwh_unadjusted,
              json.tariff_has_changed,
              json.pupils_changed,
              json.floor_area_changed
             FROM (alerts
               JOIN alert_types ON ((alerts.alert_type_id = alert_types.id))),
              LATERAL jsonb_to_record(alerts.variables) json(current_period_kwh double precision, previous_period_kwh double precision, current_period_co2 double precision, previous_period_co2 double precision, current_period_gbp double precision, previous_period_gbp double precision, previous_period_kwh_unadjusted double precision, tariff_has_changed boolean, pupils_changed boolean, floor_area_changed boolean)
            WHERE (alert_types.class_name = 'AlertConfigurablePeriodGasComparison'::text)
          ), storage_heater AS (
           SELECT alerts.alert_generation_run_id,
              alerts.comparison_report_id,
              json.current_period_kwh,
              json.previous_period_kwh,
              json.current_period_co2,
              json.previous_period_co2,
              json.current_period_gbp,
              json.previous_period_gbp,
              json.previous_period_kwh_unadjusted,
              json.tariff_has_changed,
              json.pupils_changed,
              json.floor_area_changed
             FROM (alerts
               JOIN alert_types ON ((alerts.alert_type_id = alert_types.id))),
              LATERAL jsonb_to_record(alerts.variables) json(current_period_kwh double precision, previous_period_kwh double precision, current_period_co2 double precision, previous_period_co2 double precision, current_period_gbp double precision, previous_period_gbp double precision, previous_period_kwh_unadjusted double precision, tariff_has_changed boolean, pupils_changed boolean, floor_area_changed boolean)
            WHERE (alert_types.class_name = 'AlertConfigurablePeriodStorageHeaterComparison'::text)
          ), benchmark AS (
           SELECT alerts.alert_generation_run_id,
              data.solar_type
             FROM (alerts
               JOIN alert_types ON ((alerts.alert_type_id = alert_types.id))),
              LATERAL jsonb_to_record(alerts.variables) data(solar_type text)
            WHERE (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text)
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.activation_date
             FROM (alerts
               JOIN alert_types ON ((alerts.alert_type_id = alert_types.id))),
              LATERAL jsonb_to_record(alerts.variables) data(activation_date date)
            WHERE (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text)
          ), latest_runs AS (
           SELECT ranked.id
             FROM ( SELECT alert_generation_runs.id,
                      row_number() OVER (PARTITION BY alert_generation_runs.school_id ORDER BY alert_generation_runs.created_at DESC) AS row_num
                     FROM alert_generation_runs) ranked
            WHERE (ranked.row_num = 1)
          )
   SELECT latest_runs.id,
      additional.school_id,
      additional.activation_date,
      benchmark.solar_type,
      electricity.current_period_kwh AS electricity_current_period_kwh,
      electricity.previous_period_kwh AS electricity_previous_period_kwh,
      electricity.current_period_co2 AS electricity_current_period_co2,
      electricity.previous_period_co2 AS electricity_previous_period_co2,
      electricity.current_period_gbp AS electricity_current_period_gbp,
      electricity.previous_period_gbp AS electricity_previous_period_gbp,
      electricity.tariff_has_changed AS electricity_tariff_has_changed,
      gas.current_period_kwh AS gas_current_period_kwh,
      gas.previous_period_kwh AS gas_previous_period_kwh,
      gas.current_period_co2 AS gas_current_period_co2,
      gas.previous_period_co2 AS gas_previous_period_co2,
      gas.current_period_gbp AS gas_current_period_gbp,
      gas.previous_period_gbp AS gas_previous_period_gbp,
      gas.previous_period_kwh_unadjusted AS gas_previous_period_kwh_unadjusted,
      gas.tariff_has_changed AS gas_tariff_has_changed,
      storage_heater.current_period_kwh AS storage_heater_current_period_kwh,
      storage_heater.previous_period_kwh AS storage_heater_previous_period_kwh,
      storage_heater.current_period_co2 AS storage_heater_current_period_co2,
      storage_heater.previous_period_co2 AS storage_heater_previous_period_co2,
      storage_heater.current_period_gbp AS storage_heater_current_period_gbp,
      storage_heater.previous_period_gbp AS storage_heater_previous_period_gbp,
      storage_heater.previous_period_kwh_unadjusted AS storage_heater_previous_period_kwh_unadjusted,
      storage_heater.tariff_has_changed AS storage_heater_tariff_has_changed,
      COALESCE(electricity.comparison_report_id, gas.comparison_report_id, storage_heater.comparison_report_id) AS comparison_report_id,
      (electricity.pupils_changed OR gas.pupils_changed OR storage_heater.pupils_changed) AS pupils_changed,
      (electricity.floor_area_changed OR gas.floor_area_changed OR storage_heater.floor_area_changed) AS floor_area_changed
     FROM (((((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN benchmark ON ((latest_runs.id = benchmark.alert_generation_run_id)))
       LEFT JOIN electricity ON ((latest_runs.id = electricity.alert_generation_run_id)))
       LEFT JOIN gas ON (((latest_runs.id = gas.alert_generation_run_id) AND ((electricity.comparison_report_id IS NULL) OR (electricity.comparison_report_id = gas.comparison_report_id)))))
       LEFT JOIN storage_heater ON (((latest_runs.id = storage_heater.alert_generation_run_id) AND ((gas.comparison_report_id IS NULL) OR (gas.comparison_report_id = storage_heater.comparison_report_id)) AND ((electricity.comparison_report_id IS NULL) OR (electricity.comparison_report_id = storage_heater.comparison_report_id)))));
  SQL
  add_index "comparison_configurable_periods", ["school_id", "comparison_report_id"], name: "idx_on_school_id_comparison_report_id_7e281be411", unique: true

  create_view "comparison_electricity_consumption_during_holidays", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.holiday_projected_usage_gbp,
      data.holiday_usage_to_date_gbp,
      data.holiday_type,
      data.holiday_start_date,
      data.holiday_end_date
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.holiday_projected_usage_gbp,
              data_1.holiday_usage_to_date_gbp,
              data_1.holiday_type,
              data_1.holiday_start_date,
              data_1.holiday_end_date
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(holiday_projected_usage_gbp double precision, holiday_usage_to_date_gbp double precision, holiday_type text, holiday_start_date date, holiday_end_date date)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertElectricityUsageDuringCurrentHoliday'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_electricity_consumption_during_holidays", ["school_id"], name: "idx_on_school_id_f87dfdb857", unique: true

  create_view "comparison_electricity_peak_kw_per_pupils", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.average_school_day_last_year_kw_per_floor_area,
      data.average_school_day_last_year_kw,
      data.exemplar_kw,
      data.one_year_saving_versus_exemplar_gbp,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.average_school_day_last_year_kw_per_floor_area,
              data_1.average_school_day_last_year_kw,
              data_1.exemplar_kw,
              data_1.one_year_saving_versus_exemplar_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(average_school_day_last_year_kw_per_floor_area double precision, average_school_day_last_year_kw double precision, exemplar_kw double precision, one_year_saving_versus_exemplar_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertElectricityPeakKWVersusBenchmark'::text))) data,
      ( SELECT alerts.alert_generation_run_id,
              data_1.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((data.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_electricity_peak_kw_per_pupils", ["school_id"], name: "index_comparison_electricity_peak_kw_per_pupils_on_school_id", unique: true

  create_view "comparison_electricity_targets", materialized: true, sql_definition: <<-SQL
      WITH current_targets AS (
           SELECT ranked.id
             FROM ( SELECT school_targets_1.id,
                      school_targets_1.school_id,
                      school_targets_1.target_date,
                      school_targets_1.start_date,
                      school_targets_1.electricity,
                      school_targets_1.gas,
                      school_targets_1.storage_heaters,
                      school_targets_1.created_at,
                      school_targets_1.updated_at,
                      school_targets_1.revised_fuel_types,
                      school_targets_1.report_last_generated,
                      school_targets_1.electricity_progress,
                      school_targets_1.gas_progress,
                      school_targets_1.storage_heaters_progress,
                      school_targets_1.electricity_report,
                      school_targets_1.gas_report,
                      school_targets_1.storage_heaters_report,
                      school_targets_1.electricity_monthly_consumption,
                      school_targets_1.gas_monthly_consumption,
                      school_targets_1.storage_heaters_monthly_consumption,
                      row_number() OVER (PARTITION BY school_targets_1.school_id ORDER BY school_targets_1.start_date DESC) AS rank
                     FROM school_targets school_targets_1
                    WHERE (school_targets_1.start_date < now())) ranked
            WHERE (ranked.rank = 1)
          ), totals AS (
           SELECT school_targets_1.id,
              sum(((consumption.value ->> 2))::double precision) AS current_year_kwh,
              sum(((consumption.value ->> 3))::double precision) AS previous_year_kwh,
              sum(((consumption.value ->> 4))::double precision) AS current_year_target_kwh,
              bool_or(((consumption.value ->> 7))::boolean) AS manual_readings
             FROM school_targets school_targets_1,
              LATERAL jsonb_array_elements(school_targets_1.electricity_monthly_consumption) consumption(value)
            WHERE (((NOT ((consumption.value ->> 5))::boolean) AND (NOT ((consumption.value ->> 6))::boolean)) OR ((consumption.value ->> 7))::boolean)
            GROUP BY school_targets_1.id
          )
   SELECT school_targets.school_id,
      (- school_targets.electricity) AS current_target,
      school_targets.start_date AS tracking_start_date,
      totals.id,
      totals.current_year_kwh,
      totals.previous_year_kwh,
      totals.current_year_target_kwh,
      totals.manual_readings,
      ((totals.current_year_kwh - totals.previous_year_kwh) / totals.previous_year_kwh) AS previous_to_current_year_change
     FROM ((school_targets
       JOIN totals ON ((totals.id = school_targets.id)))
       JOIN current_targets ON ((current_targets.id = school_targets.id)))
    WHERE (totals.previous_year_kwh > (0)::double precision);
  SQL
  add_index "comparison_electricity_targets", ["school_id"], name: "index_comparison_electricity_targets_on_school_id", unique: true

  create_view "comparison_gas_consumption_during_holidays", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.holiday_projected_usage_gbp,
      data.holiday_usage_to_date_gbp,
      data.holiday_type,
      data.holiday_start_date,
      data.holiday_end_date
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.holiday_projected_usage_gbp,
              data_1.holiday_usage_to_date_gbp,
              data_1.holiday_type,
              data_1.holiday_start_date,
              data_1.holiday_end_date
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(holiday_projected_usage_gbp double precision, holiday_usage_to_date_gbp double precision, holiday_type text, holiday_start_date date, holiday_end_date date)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertGasHeatingHotWaterOnDuringHoliday'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_gas_consumption_during_holidays", ["school_id"], name: "index_comparison_gas_consumption_during_holidays_on_school_id", unique: true

  create_view "comparison_gas_targets", materialized: true, sql_definition: <<-SQL
      WITH current_targets AS (
           SELECT ranked.id
             FROM ( SELECT school_targets_1.id,
                      school_targets_1.school_id,
                      school_targets_1.target_date,
                      school_targets_1.start_date,
                      school_targets_1.electricity,
                      school_targets_1.gas,
                      school_targets_1.storage_heaters,
                      school_targets_1.created_at,
                      school_targets_1.updated_at,
                      school_targets_1.revised_fuel_types,
                      school_targets_1.report_last_generated,
                      school_targets_1.electricity_progress,
                      school_targets_1.gas_progress,
                      school_targets_1.storage_heaters_progress,
                      school_targets_1.electricity_report,
                      school_targets_1.gas_report,
                      school_targets_1.storage_heaters_report,
                      school_targets_1.electricity_monthly_consumption,
                      school_targets_1.gas_monthly_consumption,
                      school_targets_1.storage_heaters_monthly_consumption,
                      row_number() OVER (PARTITION BY school_targets_1.school_id ORDER BY school_targets_1.start_date DESC) AS rank
                     FROM school_targets school_targets_1
                    WHERE (school_targets_1.start_date < now())) ranked
            WHERE (ranked.rank = 1)
          ), totals AS (
           SELECT school_targets_1.id,
              sum(((consumption.value ->> 2))::double precision) AS current_year_kwh,
              sum(((consumption.value ->> 3))::double precision) AS previous_year_kwh,
              sum(((consumption.value ->> 4))::double precision) AS current_year_target_kwh,
              bool_or(((consumption.value ->> 7))::boolean) AS manual_readings
             FROM school_targets school_targets_1,
              LATERAL jsonb_array_elements(school_targets_1.gas_monthly_consumption) consumption(value)
            WHERE (((NOT ((consumption.value ->> 5))::boolean) AND (NOT ((consumption.value ->> 6))::boolean)) OR ((consumption.value ->> 7))::boolean)
            GROUP BY school_targets_1.id
          )
   SELECT school_targets.school_id,
      (- school_targets.gas) AS current_target,
      school_targets.start_date AS tracking_start_date,
      totals.id,
      totals.current_year_kwh,
      totals.previous_year_kwh,
      totals.current_year_target_kwh,
      totals.manual_readings,
      ((totals.current_year_kwh - totals.previous_year_kwh) / totals.previous_year_kwh) AS previous_to_current_year_change
     FROM ((school_targets
       JOIN totals ON ((totals.id = school_targets.id)))
       JOIN current_targets ON ((current_targets.id = school_targets.id)))
    WHERE (totals.previous_year_kwh > (0)::double precision);
  SQL
  add_index "comparison_gas_targets", ["school_id"], name: "index_comparison_gas_targets_on_school_id", unique: true

  create_view "comparison_heating_coming_on_too_early", materialized: true, sql_definition: <<-SQL
      WITH early AS (
           SELECT alerts.alert_generation_run_id,
              json.avg_week_start_time,
              json.one_year_optimum_start_saving_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(avg_week_start_time time without time zone, one_year_optimum_start_saving_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertHeatingComingOnTooEarly'::text))
          ), optimum AS (
           SELECT alerts.alert_generation_run_id,
              json.average_start_time_hh_mm,
              json.start_time_standard_devation,
              json.rating,
              json.regression_start_time,
              json.optimum_start_sensitivity,
              json.regression_r2
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(average_start_time_hh_mm time without time zone, start_time_standard_devation double precision, rating double precision, regression_start_time double precision, optimum_start_sensitivity double precision, regression_r2 double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertOptimumStartAnalysis'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              json.gas_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(gas_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      additional.alert_generation_run_id,
      additional.school_id,
      additional.gas_economic_tariff_changed_this_year,
      early.avg_week_start_time,
      early.one_year_optimum_start_saving_gbpcurrent,
      optimum.average_start_time_hh_mm,
      optimum.start_time_standard_devation,
      optimum.rating,
      optimum.regression_start_time,
      optimum.optimum_start_sensitivity,
      optimum.regression_r2
     FROM (((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN early ON ((latest_runs.id = early.alert_generation_run_id)))
       LEFT JOIN optimum ON ((latest_runs.id = optimum.alert_generation_run_id)));
  SQL
  add_index "comparison_heating_coming_on_too_early", ["school_id"], name: "index_comparison_heating_coming_on_too_early_on_school_id", unique: true

  create_view "comparison_heating_in_warm_weathers", materialized: true, sql_definition: <<-SQL
      WITH gas AS (
           SELECT alerts.alert_generation_run_id,
              data.percent_of_annual_heating,
              data.warm_weather_heating_days_all_days_kwh,
              data.warm_weather_heating_days_all_days_co2,
              data.warm_weather_heating_days_all_days_gbpcurrent,
              data.warm_weather_heating_days_all_days_days
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(percent_of_annual_heating double precision, warm_weather_heating_days_all_days_kwh double precision, warm_weather_heating_days_all_days_co2 double precision, warm_weather_heating_days_all_days_gbpcurrent double precision, warm_weather_heating_days_all_days_days double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertSeasonalHeatingSchoolDays'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id
             FROM alerts,
              alert_types
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      additional.school_id,
      gas.percent_of_annual_heating,
      gas.warm_weather_heating_days_all_days_kwh,
      gas.warm_weather_heating_days_all_days_co2,
      gas.warm_weather_heating_days_all_days_gbpcurrent,
      gas.warm_weather_heating_days_all_days_days
     FROM ((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)));
  SQL
  add_index "comparison_heating_in_warm_weathers", ["school_id"], name: "index_comparison_heating_in_warm_weathers_on_school_id", unique: true

  create_view "comparison_heating_vs_hot_waters", materialized: true, sql_definition: <<-SQL
      WITH gas AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.last_year_kwh
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(last_year_kwh double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertGasAnnualVersusBenchmark'::text))
          ), hot_water AS (
           SELECT alerts.alert_generation_run_id,
              data.existing_gas_annual_kwh
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(existing_gas_annual_kwh double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertHotWaterEfficiency'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      gas.school_id,
      gas.last_year_kwh AS last_year_gas_kwh,
      hot_water.existing_gas_annual_kwh AS estimated_hot_water_gas_kwh,
      (hot_water.existing_gas_annual_kwh / gas.last_year_kwh) AS estimated_hot_water_percentage
     FROM ((latest_runs
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)))
       LEFT JOIN hot_water ON ((latest_runs.id = hot_water.alert_generation_run_id)));
  SQL
  add_index "comparison_heating_vs_hot_waters", ["school_id"], name: "index_comparison_heating_vs_hot_waters_on_school_id", unique: true

  create_view "comparison_holiday_and_terms", materialized: true, sql_definition: <<-SQL
      WITH electricity AS (
           SELECT alerts.alert_generation_run_id,
              json.current_period_kwh,
              json.previous_period_kwh,
              json.current_period_co2,
              json.previous_period_co2,
              json.current_period_gbp,
              json.previous_period_gbp,
              json.tariff_has_changed,
              json.pupils_changed,
              json.floor_area_changed,
              json.current_period_type,
              json.current_period_start_date,
              json.current_period_end_date,
              json.truncated_current_period
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(current_period_kwh double precision, previous_period_kwh double precision, current_period_co2 double precision, previous_period_co2 double precision, current_period_gbp double precision, previous_period_gbp double precision, tariff_has_changed boolean, pupils_changed boolean, floor_area_changed boolean, current_period_type text, current_period_start_date date, current_period_end_date date, truncated_current_period boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertHolidayAndTermElectricityComparison'::text))
          ), gas AS (
           SELECT alerts.alert_generation_run_id,
              json.current_period_kwh,
              json.previous_period_kwh,
              json.current_period_co2,
              json.previous_period_co2,
              json.current_period_gbp,
              json.previous_period_gbp,
              json.previous_period_kwh_unadjusted,
              json.tariff_has_changed,
              json.pupils_changed,
              json.floor_area_changed,
              json.current_period_type,
              json.current_period_start_date,
              json.current_period_end_date,
              json.truncated_current_period
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(current_period_kwh double precision, previous_period_kwh double precision, current_period_co2 double precision, previous_period_co2 double precision, current_period_gbp double precision, previous_period_gbp double precision, previous_period_kwh_unadjusted double precision, tariff_has_changed boolean, pupils_changed boolean, floor_area_changed boolean, current_period_type text, current_period_start_date date, current_period_end_date date, truncated_current_period boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertHolidayAndTermGasComparison'::text))
          ), storage_heater AS (
           SELECT alerts.alert_generation_run_id,
              json.current_period_kwh,
              json.previous_period_kwh,
              json.current_period_co2,
              json.previous_period_co2,
              json.current_period_gbp,
              json.previous_period_gbp,
              json.previous_period_kwh_unadjusted,
              json.tariff_has_changed,
              json.pupils_changed,
              json.floor_area_changed,
              json.current_period_type,
              json.current_period_start_date,
              json.current_period_end_date,
              json.truncated_current_period
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) json(current_period_kwh double precision, previous_period_kwh double precision, current_period_co2 double precision, previous_period_co2 double precision, current_period_gbp double precision, previous_period_gbp double precision, previous_period_kwh_unadjusted double precision, tariff_has_changed boolean, pupils_changed boolean, floor_area_changed boolean, current_period_type text, current_period_start_date date, current_period_end_date date, truncated_current_period boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertHolidayAndTermStorageHeaterComparison'::text))
          ), enba AS (
           SELECT alerts.alert_generation_run_id,
              data.solar_type
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(solar_type text)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertEnergyAnnualVersusBenchmark'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.activation_date
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(activation_date date)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      additional.school_id,
      additional.activation_date,
      (electricity.pupils_changed OR gas.pupils_changed OR storage_heater.pupils_changed) AS pupils_changed,
      (electricity.floor_area_changed OR gas.floor_area_changed OR storage_heater.floor_area_changed) AS floor_area_changed,
      enba.solar_type,
      electricity.current_period_kwh AS electricity_current_period_kwh,
      electricity.previous_period_kwh AS electricity_previous_period_kwh,
      electricity.current_period_co2 AS electricity_current_period_co2,
      electricity.previous_period_co2 AS electricity_previous_period_co2,
      electricity.current_period_gbp AS electricity_current_period_gbp,
      electricity.previous_period_gbp AS electricity_previous_period_gbp,
      electricity.tariff_has_changed AS electricity_tariff_has_changed,
      electricity.current_period_type AS electricity_current_period_type,
      electricity.current_period_start_date AS electricity_current_period_start_date,
      electricity.current_period_end_date AS electricity_current_period_end_date,
      electricity.truncated_current_period AS electricity_truncated_current_period,
      gas.current_period_kwh AS gas_current_period_kwh,
      gas.previous_period_kwh AS gas_previous_period_kwh,
      gas.current_period_co2 AS gas_current_period_co2,
      gas.previous_period_co2 AS gas_previous_period_co2,
      gas.current_period_gbp AS gas_current_period_gbp,
      gas.previous_period_gbp AS gas_previous_period_gbp,
      gas.previous_period_kwh_unadjusted AS gas_previous_period_kwh_unadjusted,
      gas.tariff_has_changed AS gas_tariff_has_changed,
      gas.current_period_type AS gas_current_period_type,
      gas.current_period_start_date AS gas_current_period_start_date,
      gas.current_period_end_date AS gas_current_period_end_date,
      gas.truncated_current_period AS gas_truncated_current_period,
      storage_heater.current_period_kwh AS storage_heater_current_period_kwh,
      storage_heater.previous_period_kwh AS storage_heater_previous_period_kwh,
      storage_heater.current_period_co2 AS storage_heater_current_period_co2,
      storage_heater.previous_period_co2 AS storage_heater_previous_period_co2,
      storage_heater.current_period_gbp AS storage_heater_current_period_gbp,
      storage_heater.previous_period_gbp AS storage_heater_previous_period_gbp,
      storage_heater.previous_period_kwh_unadjusted AS storage_heater_previous_period_kwh_unadjusted,
      storage_heater.tariff_has_changed AS storage_heater_tariff_has_changed,
      storage_heater.current_period_type AS storage_heater_current_period_type,
      storage_heater.current_period_start_date AS storage_heater_current_period_start_date,
      storage_heater.current_period_end_date AS storage_heater_current_period_end_date,
      storage_heater.truncated_current_period AS storage_heater_truncated_current_period
     FROM (((((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN electricity ON ((latest_runs.id = electricity.alert_generation_run_id)))
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)))
       LEFT JOIN storage_heater ON ((latest_runs.id = storage_heater.alert_generation_run_id)))
       LEFT JOIN enba ON ((latest_runs.id = enba.alert_generation_run_id)));
  SQL
  add_index "comparison_holiday_and_terms", ["school_id"], name: "index_comparison_holiday_and_terms_on_school_id", unique: true

  create_view "comparison_holiday_usage_last_years", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.last_year_holiday_gas_gbp,
      data.last_year_holiday_electricity_gbp,
      data.last_year_holiday_gas_gbpcurrent,
      data.last_year_holiday_electricity_gbpcurrent,
      data.last_year_holiday_gas_kwh_per_floor_area,
      data.last_year_holiday_electricity_kwh_per_floor_area,
      data.last_year_holiday_type,
      data.last_year_holiday_start_date,
      data.last_year_holiday_end_date,
      data.holiday_start_date
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.last_year_holiday_gas_gbp,
              data_1.last_year_holiday_electricity_gbp,
              data_1.last_year_holiday_gas_gbpcurrent,
              data_1.last_year_holiday_electricity_gbpcurrent,
              data_1.last_year_holiday_gas_kwh_per_floor_area,
              data_1.last_year_holiday_electricity_kwh_per_floor_area,
              data_1.last_year_holiday_type,
              data_1.last_year_holiday_start_date,
              data_1.last_year_holiday_end_date,
              data_1.holiday_start_date
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(last_year_holiday_gas_gbp double precision, last_year_holiday_electricity_gbp double precision, last_year_holiday_gas_gbpcurrent double precision, last_year_holiday_electricity_gbpcurrent double precision, last_year_holiday_gas_kwh_per_floor_area double precision, last_year_holiday_electricity_kwh_per_floor_area double precision, last_year_holiday_type text, last_year_holiday_start_date date, last_year_holiday_end_date date, holiday_start_date date)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertImpendingHoliday'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_holiday_usage_last_years", ["school_id"], name: "index_comparison_holiday_usage_last_years_on_school_id", unique: true

  create_view "comparison_hot_water_efficiencies", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.avg_gas_per_pupil_gbp,
      data.benchmark_existing_gas_efficiency,
      data.benchmark_gas_better_control_saving_gbp,
      data.benchmark_point_of_use_electric_saving_gbp
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.avg_gas_per_pupil_gbp,
              data_1.benchmark_existing_gas_efficiency,
              data_1.benchmark_gas_better_control_saving_gbp,
              data_1.benchmark_point_of_use_electric_saving_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(avg_gas_per_pupil_gbp double precision, benchmark_existing_gas_efficiency double precision, benchmark_gas_better_control_saving_gbp double precision, benchmark_point_of_use_electric_saving_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertHotWaterEfficiency'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_hot_water_efficiencies", ["school_id"], name: "index_comparison_hot_water_efficiencies_on_school_id", unique: true

  create_view "comparison_recent_change_in_baseloads", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.predicted_percent_increase_in_usage,
      data.average_baseload_last_year_kw,
      data.average_baseload_last_week_kw,
      data.change_in_baseload_kw,
      data.next_year_change_in_baseload_gbpcurrent,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.predicted_percent_increase_in_usage,
              data_1.average_baseload_last_year_kw,
              data_1.average_baseload_last_week_kw,
              data_1.change_in_baseload_kw,
              data_1.next_year_change_in_baseload_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(predicted_percent_increase_in_usage double precision, average_baseload_last_year_kw double precision, average_baseload_last_week_kw double precision, change_in_baseload_kw double precision, next_year_change_in_baseload_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertChangeInElectricityBaseloadShortTerm'::text))) data,
      ( SELECT alerts.alert_generation_run_id,
              data_1.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((data.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_recent_change_in_baseloads", ["school_id"], name: "index_comparison_recent_change_in_baseloads_on_school_id", unique: true

  create_view "comparison_seasonal_baseload_variations", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      additional.school_id,
      data.alert_generation_run_id,
      data.percent_seasonal_variation,
      data.summer_kw,
      data.winter_kw,
      data.annual_cost_gbpcurrent,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              data_1.percent_seasonal_variation,
              data_1.summer_kw,
              data_1.winter_kw,
              data_1.annual_cost_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(percent_seasonal_variation double precision, summer_kw double precision, winter_kw double precision, annual_cost_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertSeasonalBaseloadVariation'::text))) data,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((data.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_seasonal_baseload_variations", ["school_id"], name: "index_comparison_seasonal_baseload_variations_on_school_id", unique: true

  create_view "comparison_solar_generation_summaries", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      solar_generation.alert_generation_run_id,
      solar_generation.school_id,
      solar_generation.annual_electricity_kwh,
      solar_generation.annual_mains_consumed_kwh,
      solar_generation.annual_solar_pv_kwh,
      solar_generation.annual_exported_solar_pv_kwh,
      solar_generation.annual_solar_pv_consumed_onsite_kwh
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.annual_electricity_kwh,
              data.annual_mains_consumed_kwh,
              data.annual_solar_pv_kwh,
              data.annual_exported_solar_pv_kwh,
              data.annual_solar_pv_consumed_onsite_kwh
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(annual_electricity_kwh double precision, annual_mains_consumed_kwh double precision, annual_solar_pv_kwh double precision, annual_exported_solar_pv_kwh double precision, annual_solar_pv_consumed_onsite_kwh double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertSolarGeneration'::text))) solar_generation,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (solar_generation.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_solar_generation_summaries", ["school_id"], name: "index_comparison_solar_generation_summaries_on_school_id", unique: true

  create_view "comparison_solar_pv_benefit_estimates", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      additional.school_id,
      benefit_estimate.alert_generation_run_id,
      benefit_estimate.optimum_kwp,
      benefit_estimate.optimum_payback_years,
      benefit_estimate.optimum_mains_reduction_percent,
      benefit_estimate.one_year_saving_gbpcurrent,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              data.optimum_kwp,
              data.optimum_payback_years,
              data.optimum_mains_reduction_percent,
              data.one_year_saving_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(optimum_kwp double precision, optimum_payback_years double precision, optimum_mains_reduction_percent double precision, one_year_saving_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertSolarPVBenefitEstimator'::text))) benefit_estimate,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((benefit_estimate.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_solar_pv_benefit_estimates", ["school_id"], name: "index_comparison_solar_pv_benefit_estimates_on_school_id", unique: true

  create_view "comparison_storage_heater_consumption_during_holidays", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data.holiday_projected_usage_gbp,
      data.holiday_usage_to_date_gbp,
      data.holiday_type,
      data.holiday_start_date,
      data.holiday_end_date
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.holiday_projected_usage_gbp,
              data_1.holiday_usage_to_date_gbp,
              data_1.holiday_type,
              data_1.holiday_start_date,
              data_1.holiday_end_date
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(holiday_projected_usage_gbp double precision, holiday_usage_to_date_gbp double precision, holiday_type text, holiday_start_date date, holiday_end_date date)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterHeatingOnDuringHoliday'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_storage_heater_consumption_during_holidays", ["school_id"], name: "idx_on_school_id_43b0326934", unique: true

  create_view "comparison_thermostat_sensitivities", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      data.alert_generation_run_id,
      data.school_id,
      data."annual_saving_1_C_change_gbp"
     FROM ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1."annual_saving_1_C_change_gbp"
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1("annual_saving_1_C_change_gbp" double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertHeatingSensitivityAdvice'::text))) data,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE (data.alert_generation_run_id = latest_runs.id);
  SQL
  add_index "comparison_thermostat_sensitivities", ["school_id"], name: "index_comparison_thermostat_sensitivities_on_school_id", unique: true

  create_view "comparison_thermostatic_controls", materialized: true, sql_definition: <<-SQL
      WITH gas AS (
           SELECT alerts.alert_generation_run_id,
              data.r2,
              data.potential_saving_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(r2 double precision, potential_saving_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertThermostaticControl'::text))
          ), storage_heaters AS (
           SELECT alerts.alert_generation_run_id,
              data.r2,
              data.potential_saving_gbp
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data(r2 double precision, potential_saving_gbp double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertStorageHeaterThermostatic'::text))
          ), additional AS (
           SELECT alerts.alert_generation_run_id,
              alerts.school_id
             FROM alerts,
              alert_types
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))
          ), latest_runs AS (
           SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC
          )
   SELECT latest_runs.id,
      additional.school_id,
      COALESCE(gas.r2, storage_heaters.r2) AS r2,
      NULLIF((COALESCE(gas.potential_saving_gbp, (0)::double precision) + COALESCE(storage_heaters.potential_saving_gbp, (0)::double precision)), (0)::double precision) AS potential_saving_gbp
     FROM (((latest_runs
       JOIN additional ON ((latest_runs.id = additional.alert_generation_run_id)))
       LEFT JOIN gas ON ((latest_runs.id = gas.alert_generation_run_id)))
       LEFT JOIN storage_heaters ON ((latest_runs.id = storage_heaters.alert_generation_run_id)));
  SQL
  add_index "comparison_thermostatic_controls", ["school_id"], name: "index_comparison_thermostatic_controls_on_school_id", unique: true

  create_view "comparison_weekday_baseload_variations", materialized: true, sql_definition: <<-SQL
      SELECT latest_runs.id,
      additional.school_id,
      data.alert_generation_run_id,
      data.percent_intraday_variation,
      data.min_day_kw,
      data.max_day_kw,
      data.min_day,
      data.max_day,
      data.annual_cost_gbpcurrent,
      additional.electricity_economic_tariff_changed_this_year
     FROM ( SELECT alerts.alert_generation_run_id,
              data_1.percent_intraday_variation,
              data_1.min_day_kw,
              data_1.max_day_kw,
              data_1.min_day,
              data_1.max_day,
              data_1.annual_cost_gbpcurrent
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(percent_intraday_variation double precision, min_day_kw double precision, max_day_kw double precision, min_day integer, max_day integer, annual_cost_gbpcurrent double precision)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertIntraweekBaseloadVariation'::text))) data,
      ( SELECT alerts.alert_generation_run_id,
              alerts.school_id,
              data_1.electricity_economic_tariff_changed_this_year
             FROM alerts,
              alert_types,
              LATERAL jsonb_to_record(alerts.variables) data_1(electricity_economic_tariff_changed_this_year boolean)
            WHERE ((alerts.alert_type_id = alert_types.id) AND (alert_types.class_name = 'AlertAdditionalPrioritisationData'::text))) additional,
      ( SELECT DISTINCT ON (alert_generation_runs.school_id) alert_generation_runs.id
             FROM alert_generation_runs
            ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC) latest_runs
    WHERE ((data.alert_generation_run_id = latest_runs.id) AND (additional.alert_generation_run_id = latest_runs.id));
  SQL
  add_index "comparison_weekday_baseload_variations", ["school_id"], name: "index_comparison_weekday_baseload_variations_on_school_id", unique: true

  create_view "report_baseload_anomalies", materialized: true, sql_definition: <<-SQL
      WITH unnested_readings_with_index AS (
           SELECT amr.id,
              amr.meter_id,
              amr.reading_date,
              (EXISTS ( SELECT 1
                     FROM meter_attributes ma
                    WHERE ((ma.meter_id = amr.meter_id) AND (((ma.attribute_type)::text = 'solar_pv_mpan_meter_mapping'::text) OR ((ma.attribute_type)::text = 'solar_pv'::text)) AND (ma.deleted_by_id IS NULL) AND (ma.replaced_by_id IS NULL)))) AS has_solar,
              (t.val * 2.0) AS val_kw,
              t.ordinality AS index
             FROM ((amr_validated_readings amr
               JOIN meters m ON ((amr.meter_id = m.id)))
               CROSS JOIN LATERAL unnest(amr.kwh_data_x48) WITH ORDINALITY t(val, ordinality))
            WHERE ((amr.reading_date >= (CURRENT_DATE - 'P31D'::interval)) AND (m.meter_type = 0) AND (m.active = true))
          ), unnested_readings_with_index_and_ranking AS (
           SELECT unnested_readings_with_index.id,
              unnested_readings_with_index.meter_id,
              unnested_readings_with_index.reading_date,
              unnested_readings_with_index.has_solar,
              unnested_readings_with_index.val_kw,
              unnested_readings_with_index.index,
              row_number() OVER (PARTITION BY unnested_readings_with_index.meter_id, unnested_readings_with_index.reading_date ORDER BY unnested_readings_with_index.val_kw) AS ranking
             FROM unnested_readings_with_index
          ), daily_baseload AS (
           SELECT unnested_readings_with_index_and_ranking.id,
              unnested_readings_with_index_and_ranking.meter_id,
              unnested_readings_with_index_and_ranking.reading_date,
                  CASE
                      WHEN unnested_readings_with_index_and_ranking.has_solar THEN avg(
                      CASE
                          WHEN (((unnested_readings_with_index_and_ranking.index >= 1) AND (unnested_readings_with_index_and_ranking.index <= 4)) OR ((unnested_readings_with_index_and_ranking.index >= 45) AND (unnested_readings_with_index_and_ranking.index <= 48))) THEN unnested_readings_with_index_and_ranking.val_kw
                          ELSE NULL::numeric
                      END)
                      ELSE avg(
                      CASE
                          WHEN (unnested_readings_with_index_and_ranking.ranking <= 8) THEN unnested_readings_with_index_and_ranking.val_kw
                          ELSE NULL::numeric
                      END)
                  END AS selected_avg
             FROM unnested_readings_with_index_and_ranking
            GROUP BY unnested_readings_with_index_and_ranking.id, unnested_readings_with_index_and_ranking.meter_id, unnested_readings_with_index_and_ranking.reading_date, unnested_readings_with_index_and_ranking.has_solar
          ), last_two_days_baseload AS (
           SELECT t1.id,
              t1.meter_id,
              t1.reading_date,
              t1.selected_avg AS today_baseload,
              t2.selected_avg AS previous_day_baseload
             FROM (daily_baseload t1
               LEFT JOIN daily_baseload t2 ON (((t1.meter_id = t2.meter_id) AND (t1.reading_date = (t2.reading_date + 'P1D'::interval)))))
            WHERE (t1.reading_date >= (CURRENT_DATE - 'P30D'::interval))
          )
   SELECT last_two_days_baseload.id,
      last_two_days_baseload.meter_id,
      last_two_days_baseload.reading_date,
      last_two_days_baseload.today_baseload,
      last_two_days_baseload.previous_day_baseload
     FROM last_two_days_baseload
    WHERE ((last_two_days_baseload.previous_day_baseload IS NOT NULL) AND (last_two_days_baseload.previous_day_baseload > 0.5) AND (((last_two_days_baseload.today_baseload >= (0)::numeric) AND (last_two_days_baseload.today_baseload < 0.01)) OR (last_two_days_baseload.previous_day_baseload >= (last_two_days_baseload.today_baseload * (5)::numeric))));
  SQL
  add_index "report_baseload_anomalies", ["id"], name: "index_report_baseload_anomalies_on_id", unique: true

  create_view "report_gas_anomalies", materialized: true, sql_definition: <<-SQL
      WITH readings_with_temperature_and_event AS (
           SELECT amr.id,
              amr.meter_id,
              amr.reading_date,
              amr.one_day_kwh,
              round(avg(temp.temp), 2) AS average_temperature,
              round(GREATEST((15.5 - avg(temp.temp)), (0)::numeric), 2) AS heating_degree_days,
              calendar_events.calendar_event_type_id
             FROM ((((((((amr_validated_readings amr
               JOIN meters ON ((amr.meter_id = meters.id)))
               JOIN schools ON ((meters.school_id = schools.id)))
               JOIN calendars ON ((schools.calendar_id = calendars.id)))
               JOIN calendar_events ON (((calendars.id = calendar_events.calendar_id) AND ((amr.reading_date >= calendar_events.start_date) AND (amr.reading_date <= calendar_events.end_date)))))
               JOIN calendar_event_types ON ((calendar_events.calendar_event_type_id = calendar_event_types.id)))
               JOIN weather_stations ON ((schools.weather_station_id = weather_stations.id)))
               JOIN weather_observations ON (((weather_stations.id = weather_observations.weather_station_id) AND (weather_observations.reading_date = amr.reading_date))))
               JOIN LATERAL unnest(weather_observations.temperature_celsius_x48) temp(temp) ON (true))
            WHERE ((amr.reading_date >= (CURRENT_DATE - 'P67D'::interval)) AND (calendar_event_types.inset_day = false) AND (calendar_event_types.bank_holiday = false) AND (meters.active = true) AND (meters.meter_type = 1))
            GROUP BY amr.id, amr.reading_date, calendar_events.calendar_event_type_id
          )
   SELECT today.id,
      today.meter_id,
      today.reading_date,
      today.one_day_kwh AS today_kwh,
      today.average_temperature AS today_temperature,
      today.heating_degree_days AS today_degree_days,
      previous_day.reading_date AS previous_reading_date,
      previous_day.one_day_kwh AS previous_kwh,
      previous_day.average_temperature AS previous_temperature,
      previous_day.heating_degree_days AS previous_degree_days,
      today.calendar_event_type_id
     FROM (readings_with_temperature_and_event previous_day
       LEFT JOIN readings_with_temperature_and_event today ON (((today.meter_id = previous_day.meter_id) AND (today.reading_date = (previous_day.reading_date + 'P7D'::interval)))))
    WHERE ((previous_day.one_day_kwh IS NOT NULL) AND (previous_day.calendar_event_type_id = today.calendar_event_type_id) AND (previous_day.one_day_kwh > 0.0) AND (today.one_day_kwh > ((10)::numeric * previous_day.one_day_kwh)) AND (abs((today.heating_degree_days - previous_day.heating_degree_days)) < 2.0));
  SQL
  add_index "report_gas_anomalies", ["id"], name: "index_report_gas_anomalies_on_id", unique: true

end
