SELECT latest_runs.id,
  data.*
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      schoolday_open_percent float,
      schoolday_closed_percent float,
      holidays_percent float,
      weekends_percent float,
      holidays_gbp float,
      weekends_gbp float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertStorageHeaterOutOfHours'
  ) AS data,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id;

