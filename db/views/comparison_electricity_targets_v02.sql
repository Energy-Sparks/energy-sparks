SELECT latest_runs.id,
       data.*
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      current_year_percent_of_target_relative float,
      current_year_kwh float,
      current_year_target_kwh float,
      tracking_start_date date
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertElectricityTargetAnnual'
  ) AS data,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id;
