WITH gas AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_kwh float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertGasAnnualVersusBenchmark'
), hot_water AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    existing_gas_annual_kwh float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertHotWaterEfficiency'
), latest_runs AS (
  SELECT DISTINCT ON (school_id) id
  FROM alert_generation_runs
  ORDER BY school_id, created_at DESC
)
SELECT latest_runs.id,
  gas.school_id,
  gas.last_year_kwh AS last_year_gas_kwh,
  hot_water.existing_gas_annual_kwh AS estimated_hot_water_gas_kwh,
  hot_water.existing_gas_annual_kwh / gas.last_year_kwh AS estimated_hot_water_percentage
FROM latest_runs
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN hot_water ON latest_runs.id = hot_water.alert_generation_run_id;
