WITH electricity AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_gbp float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertElectricityAnnualVersusBenchmark'
), gas AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_gbp float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertGasAnnualVersusBenchmark'
), storage_heaters AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_gbp float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertStorageHeaterAnnualVersusBenchmark'
), energy AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_gbp float,
    one_year_energy_per_pupil_gbp float,
    "last_year_co2_tonnes" float,
    last_year_kwh float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
), additional AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    school_type_name text,
    pupils float,
    floor_area float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
), latest_runs AS (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
)
SELECT latest_runs.id,
  electricity.last_year_gbp as last_year_electricity,
  gas.last_year_gbp as last_year_gas,
  storage_heaters.last_year_gbp as last_year_storage_heaters,
  energy.last_year_gbp,
  energy.one_year_energy_per_pupil_gbp,
  energy.last_year_co2_tonnes,
  energy.last_year_kwh,
  additional.*
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN electricity ON latest_runs.id = electricity.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heaters ON latest_runs.id = storage_heaters.alert_generation_run_id
LEFT JOIN energy ON latest_runs.id = energy.alert_generation_run_id;
