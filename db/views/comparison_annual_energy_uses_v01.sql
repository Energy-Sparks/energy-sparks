WITH electricity AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_kwh float,
    last_year_co2 float,
    last_year_gbp float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertElectricityAnnualVersusBenchmark'
), gas AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_kwh float,
    last_year_co2 float,
    last_year_gbp float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertGasAnnualVersusBenchmark'
), storage_heaters AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    last_year_kwh float,
    last_year_co2 float,
    last_year_gbp float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertStorageHeaterAnnualVersusBenchmark'
), additional AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    electricity_economic_tariff_changed_this_year boolean,
    gas_economic_tariff_changed_this_year boolean,
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
  electricity.last_year_kwh as electricity_last_year_kwh,
  electricity.last_year_gbp as electricity_last_year_gbp,
  electricity.last_year_co2 as electricity_last_year_co2,
  gas.last_year_kwh as gas_last_year_kwh,
  gas.last_year_gbp as gas_last_year_gbp,
  gas.last_year_co2 as gas_last_year_co2,
  storage_heaters.last_year_kwh as storage_heaters_last_year_kwh,
  storage_heaters.last_year_gbp as storage_heaters_last_year_gbp,
  storage_heaters.last_year_co2 as storage_heaters_last_year_co2,
  additional.electricity_economic_tariff_changed_this_year as electricity_tariff_has_changed,
  additional.gas_economic_tariff_changed_this_year as gas_tariff_has_changed,
  additional.school_type_name,
  additional.pupils,
  additional.floor_area,
  additional.school_id,
  additional.alert_generation_run_id
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN electricity ON latest_runs.id = electricity.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heaters ON latest_runs.id = storage_heaters.alert_generation_run_id;
