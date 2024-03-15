WITH gas AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    "r2" float,
    potential_saving_gbp float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertThermostaticControl'
), storage_heaters AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    "r2" float,
    potential_saving_gbp float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertStorageHeaterThermostatic'
), additional AS (
  SELECT alert_generation_run_id, school_id
  FROM alerts, alert_types
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
), latest_runs AS (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
)
SELECT latest_runs.id,
  additional.school_id,
  COALESCE(gas.r2, storage_heaters.r2) as r2,
  NULLIF(COALESCE(gas.potential_saving_gbp, 0) + COALESCE(storage_heaters.potential_saving_gbp, 0), 0) as potential_saving_gbp
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heaters ON latest_runs.id = storage_heaters.alert_generation_run_id;
