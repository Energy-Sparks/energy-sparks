SELECT latest_runs.id,
       data.*
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      current_period_type text,
      difference_gbpcurrent float,
      difference_kwh float,
      difference_percent float,
      previous_period_type text,
      pupils_changed boolean,
      tariff_has_changed boolean,
      truncated_current_period boolean
    )
    WHERE alerts.alert_type_id = alert_types.id and
      alert_types.class_name='AlertPreviousYearHolidayComparisonElectricity'
  ) AS data,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id;
