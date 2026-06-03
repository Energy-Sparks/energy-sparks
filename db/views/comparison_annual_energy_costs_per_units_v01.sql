WITH electricity AS (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      one_year_electricity_per_pupil_kwh float,
      one_year_electricity_per_pupil_gbp float,
      one_year_electricity_per_pupil_co2 float,
      one_year_electricity_per_floor_area_kwh float,
      one_year_electricity_per_floor_area_gbp float,
      one_year_electricity_per_floor_area_co2 float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertElectricityAnnualVersusBenchmark'
), gas AS (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      one_year_gas_per_pupil_kwh float,
      one_year_gas_per_pupil_gbp float,
      one_year_gas_per_pupil_co2 float,
      one_year_gas_per_floor_area_kwh float,
      one_year_gas_per_floor_area_gbp float,
      one_year_gas_per_floor_area_co2 float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertGasAnnualVersusBenchmark'
), storage_heaters AS (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      one_year_gas_per_pupil_kwh float,
      one_year_gas_per_pupil_gbp float,
      one_year_gas_per_pupil_co2 float,
      one_year_gas_per_floor_area_kwh float,
      one_year_gas_per_floor_area_gbp float,
      one_year_gas_per_floor_area_co2 float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertStorageHeaterAnnualVersusBenchmark'
), additional AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    electricity_economic_tariff_changed_this_year boolean,
    gas_economic_tariff_changed_this_year boolean,
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
       electricity.one_year_electricity_per_pupil_kwh,
       electricity.one_year_electricity_per_pupil_gbp,
       electricity.one_year_electricity_per_pupil_co2,
       electricity.one_year_electricity_per_floor_area_kwh,
       electricity.one_year_electricity_per_floor_area_gbp,
       electricity.one_year_electricity_per_floor_area_co2,
       gas.one_year_gas_per_pupil_kwh,
       gas.one_year_gas_per_pupil_gbp,
       gas.one_year_gas_per_pupil_co2,
       gas.one_year_gas_per_floor_area_kwh,
       gas.one_year_gas_per_floor_area_gbp,
       gas.one_year_gas_per_floor_area_co2,
       storage_heaters.one_year_gas_per_pupil_kwh AS one_year_storage_heater_per_pupil_kwh,
       storage_heaters.one_year_gas_per_pupil_gbp AS one_year_storage_heater_per_pupil_gbp,
       storage_heaters.one_year_gas_per_pupil_co2 AS one_year_storage_heater_per_pupil_co2,
       storage_heaters.one_year_gas_per_floor_area_kwh AS one_year_storage_heater_per_floor_area_kwh,
       storage_heaters.one_year_gas_per_floor_area_gbp AS one_year_storage_heater_per_floor_area_gbp,
       storage_heaters.one_year_gas_per_floor_area_co2 AS one_year_storage_heater_per_floor_area_co2,
       additional.school_id,
       additional.electricity_economic_tariff_changed_this_year,
       additional.gas_economic_tariff_changed_this_year,
       additional.pupils,
       additional.floor_area
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN electricity ON latest_runs.id = electricity.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heaters ON latest_runs.id = storage_heaters.alert_generation_run_id;
