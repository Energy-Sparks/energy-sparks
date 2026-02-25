SELECT DISTINCT ON (alert_generation_runs.school_id) alerts.school_id, alert_generation_runs.id, data.*
FROM alert_generation_runs
JOIN alerts ON alerts.alert_generation_run_id = alert_generation_runs.id
JOIN alert_types ON alert_types.id = alerts.alert_type_id
CROSS JOIN LATERAL jsonb_to_record(alerts.variables) AS data(holiday_projected_usage_gbp float,
                                                             holiday_usage_to_date_gbp float,
                                                             holiday_type text,
                                                             holiday_start_date date,
                                                             holiday_end_date date)
WHERE (alert_types.class_name = 'Alerts::StorageHeater::HeatingOnDuringHolidayWithCommunityUse'
       AND alerts.enough_data = 1)
  OR alert_types.class_name = 'AlertStorageHeaterHeatingOnDuringHoliday'
ORDER BY alert_generation_runs.school_id, alert_generation_runs.created_at DESC,
  CASE WHEN alert_types.class_name = 'Alerts::StorageHeater::HeatingOnDuringHolidayWithCommunityUse'
    THEN 0 ELSE 1 END
