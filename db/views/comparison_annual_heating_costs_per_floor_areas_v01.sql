WITH gas AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    one_year_gas_per_floor_area_normalised_gbp float,
    last_year_gbp float,
    one_year_saving_versus_exemplar_gbpcurrent float,
    last_year_kwh float,
    last_year_co2 float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertGasAnnualVersusBenchmark'
), storage_heaters AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    one_year_gas_per_floor_area_normalised_gbp float,
    last_year_gbp float,
    one_year_saving_versus_exemplar_gbpcurrent float,
    last_year_kwh float,
    last_year_co2 float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertStorageHeaterAnnualVersusBenchmark'
), additional AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    gas_economic_tariff_changed_this_year boolean
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
), latest_runs AS (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
)
SELECT latest_runs.id,
  additional.school_id,
  COALESCE(gas.one_year_gas_per_floor_area_normalised_gbp, 0) + COALESCE(storage_heaters.one_year_gas_per_floor_area_normalised_gbp, 0) as one_year_gas_per_floor_area_normalised_gbp,
  COALESCE(gas.last_year_gbp, 0) + COALESCE(storage_heaters.last_year_gbp, 0) as last_year_gbp,
  COALESCE(gas.one_year_saving_versus_exemplar_gbpcurrent, 0) + COALESCE(storage_heaters.one_year_saving_versus_exemplar_gbpcurrent, 0) as one_year_saving_versus_exemplar_gbpcurrent,
  COALESCE(gas.last_year_kwh, 0) + COALESCE(storage_heaters.last_year_kwh, 0) as last_year_kwh,
  COALESCE(gas.last_year_co2, 0) + COALESCE(storage_heaters.last_year_co2, 0) as last_year_co2,
  gas.last_year_co2 as gas_last_year_co2,
  additional.gas_economic_tariff_changed_this_year
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heaters ON latest_runs.id = storage_heaters.alert_generation_run_id;
