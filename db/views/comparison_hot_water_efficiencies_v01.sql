SELECT latest_runs.id,
       data.*
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      avg_gas_per_pupil_gbp float,
      benchmark_existing_gas_efficiency float,
      benchmark_gas_better_control_saving_gbp float,
      benchmark_point_of_use_electric_saving_gbp float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertHotWaterEfficiency'
  ) AS data,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id;
