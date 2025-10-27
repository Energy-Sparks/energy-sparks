WITH gas AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    one_year_gas_per_floor_area_gbp float,
    one_year_gas_per_floor_area_kwh float,
    one_year_gas_per_floor_area_co2 float,
    last_year_gbp float,
    last_year_kwh float,
    last_year_co2 float,
    one_year_saving_versus_exemplar_gbpcurrent float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertGasAnnualVersusBenchmark'
), storage_heaters AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    one_year_gas_per_floor_area_gbp float,
    one_year_gas_per_floor_area_kwh float,
    one_year_gas_per_floor_area_co2 float,
    last_year_gbp float,
    last_year_kwh float,
    last_year_co2 float,
    one_year_saving_versus_exemplar_gbpcurrent float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertStorageHeaterAnnualVersusBenchmark'
), additional AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    gas_economic_tariff_changed_this_year boolean,
    electricity_economic_tariff_changed_this_year boolean
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
), latest_runs AS (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
)
SELECT latest_runs.id,
  additional.school_id,

  gas.last_year_gbp as gas_last_year_gbp,
  gas.last_year_kwh as gas_last_year_kwh,
  gas.last_year_co2 as gas_last_year_co2,

  gas.one_year_gas_per_floor_area_gbp as one_year_gas_per_floor_area_gbp,
  gas.one_year_gas_per_floor_area_kwh as one_year_gas_per_floor_area_kwh,
  gas.one_year_gas_per_floor_area_co2 as one_year_gas_per_floor_area_co2,

  storage_heaters.last_year_gbp as storage_heaters_last_year_gbp,
  storage_heaters.last_year_kwh as storage_heaters_last_year_kwh,
  storage_heaters.last_year_co2 as storage_heaters_last_year_co2,

  storage_heaters.one_year_gas_per_floor_area_gbp as one_year_storage_heaters_per_floor_area_gbp,
  storage_heaters.one_year_gas_per_floor_area_kwh as one_year_storage_heaters_per_floor_area_kwh,
  storage_heaters.one_year_gas_per_floor_area_co2 as one_year_storage_heaters_per_floor_area_co2,

  gas.one_year_saving_versus_exemplar_gbpcurrent as one_year_gas_saving_versus_exemplar_gbpcurrent,
  storage_heaters.one_year_saving_versus_exemplar_gbpcurrent as one_year_storage_heaters_saving_versus_exemplar_gbpcurrent,

  additional.gas_economic_tariff_changed_this_year,
  additional.electricity_economic_tariff_changed_this_year
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heaters ON latest_runs.id = storage_heaters.alert_generation_run_id;
