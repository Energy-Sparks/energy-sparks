WITH electricity AS (
  SELECT alert_generation_run_id, json.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS json(
    current_period_kwh float,
    previous_period_kwh float,
    current_period_co2 float,
    previous_period_co2 float,
    current_period_gbp float,
    previous_period_gbp float,
    tariff_has_changed boolean,
    pupils_changed boolean,
    floor_area_changed boolean,
    current_period_type text,
    current_period_start_date date,
    current_period_end_date date,
    truncated_current_period boolean
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertHolidayAndTermElectricityComparison'
), gas AS (
  SELECT alert_generation_run_id, json.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS json(
    current_period_kwh float,
    previous_period_kwh float,
    current_period_co2 float,
    previous_period_co2 float,
    current_period_gbp float,
    previous_period_gbp float,
    previous_period_kwh_unadjusted float,
    tariff_has_changed boolean,
    pupils_changed boolean,
    floor_area_changed boolean,
    current_period_type text,
    current_period_start_date date,
    current_period_end_date date,
    truncated_current_period boolean
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertHolidayAndTermGasComparison'
), storage_heater AS (
  SELECT alert_generation_run_id, json.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS json(
    current_period_kwh float,
    previous_period_kwh float,
    current_period_co2 float,
    previous_period_co2 float,
    current_period_gbp float,
    previous_period_gbp float,
    previous_period_kwh_unadjusted float,
    tariff_has_changed boolean,
    pupils_changed boolean,
    floor_area_changed boolean,
    current_period_type text,
    current_period_start_date date,
    current_period_end_date date,
    truncated_current_period boolean
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertHolidayAndTermStorageHeaterComparison'
), enba AS (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      solar_type text
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
), additional AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    activation_date date
    )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
), latest_runs AS (
  SELECT DISTINCT ON (school_id) id
  FROM alert_generation_runs
  ORDER BY school_id, created_at DESC
)
SELECT latest_runs.id,
       additional.school_id,
       additional.activation_date,
       (electricity.pupils_changed OR gas.pupils_changed OR storage_heater.pupils_changed) AS pupils_changed,
       (electricity.floor_area_changed OR gas.floor_area_changed OR storage_heater.floor_area_changed) AS floor_area_changed,
       enba.solar_type AS solar_type,
       electricity.current_period_kwh AS electricity_current_period_kwh,
       electricity.previous_period_kwh AS electricity_previous_period_kwh,
       electricity.current_period_co2 AS electricity_current_period_co2,
       electricity.previous_period_co2 AS electricity_previous_period_co2,
       electricity.current_period_gbp AS electricity_current_period_gbp,
       electricity.previous_period_gbp AS electricity_previous_period_gbp,
       electricity.tariff_has_changed AS electricity_tariff_has_changed,
       electricity.current_period_type AS electricity_current_period_type,
       electricity.current_period_start_date AS electricity_current_period_start_date,
       electricity.current_period_end_date AS electricity_current_period_end_date,
       electricity.truncated_current_period AS electricity_truncated_current_period,
       gas.current_period_kwh AS gas_current_period_kwh,
       gas.previous_period_kwh AS gas_previous_period_kwh,
       gas.current_period_co2 AS gas_current_period_co2,
       gas.previous_period_co2 AS gas_previous_period_co2,
       gas.current_period_gbp AS gas_current_period_gbp,
       gas.previous_period_gbp AS gas_previous_period_gbp,
       gas.previous_period_kwh_unadjusted as gas_previous_period_kwh_unadjusted,
       gas.tariff_has_changed AS gas_tariff_has_changed,
       gas.current_period_type AS gas_current_period_type,
       gas.current_period_start_date AS gas_current_period_start_date,
       gas.current_period_end_date AS gas_current_period_end_date,
       gas.truncated_current_period AS gas_truncated_current_period,
       storage_heater.current_period_kwh AS storage_heater_current_period_kwh,
       storage_heater.previous_period_kwh AS storage_heater_previous_period_kwh,
       storage_heater.current_period_co2 AS storage_heater_current_period_co2,
       storage_heater.previous_period_co2 AS storage_heater_previous_period_co2,
       storage_heater.current_period_gbp AS storage_heater_current_period_gbp,
       storage_heater.previous_period_gbp AS storage_heater_previous_period_gbp,
       storage_heater.previous_period_kwh_unadjusted AS storage_heater_previous_period_kwh_unadjusted,
       storage_heater.tariff_has_changed AS storage_heater_tariff_has_changed,
       storage_heater.current_period_type AS storage_heater_current_period_type,
       storage_heater.current_period_start_date AS storage_heater_current_period_start_date,
       storage_heater.current_period_end_date AS storage_heater_current_period_end_date,
       storage_heater.truncated_current_period AS storage_heater_truncated_current_period
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN electricity ON latest_runs.id = electricity.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heater ON latest_runs.id = storage_heater.alert_generation_run_id
LEFT JOIN enba ON latest_runs.id = enba.alert_generation_run_id
