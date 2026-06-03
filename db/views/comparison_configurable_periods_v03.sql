WITH electricity AS (
  SELECT alert_generation_run_id, comparison_report_id, json.*
  FROM alerts
  JOIN alert_types ON alerts.alert_type_id = alert_types.id,
    jsonb_to_record(variables) AS json(
      current_period_kwh float,
      previous_period_kwh float,
      current_period_co2 float,
      previous_period_co2 float,
      current_period_gbp float,
      previous_period_gbp float,
      tariff_has_changed boolean,
      pupils_changed boolean,
      floor_area_changed boolean
    )
  WHERE alert_types.class_name='AlertConfigurablePeriodElectricityComparison'
), gas AS (
  SELECT alert_generation_run_id, comparison_report_id, json.*
  FROM alerts
  JOIN alert_types ON alerts.alert_type_id = alert_types.id,
    jsonb_to_record(variables) AS json(
      current_period_kwh float,
      previous_period_kwh float,
      current_period_co2 float,
      previous_period_co2 float,
      current_period_gbp float,
      previous_period_gbp float,
      previous_period_kwh_unadjusted float,
      tariff_has_changed boolean,
      pupils_changed boolean,
      floor_area_changed boolean
    )
  WHERE alert_types.class_name='AlertConfigurablePeriodGasComparison'
), storage_heater AS (
  SELECT alert_generation_run_id, comparison_report_id, json.*
  FROM alerts
  JOIN alert_types ON alerts.alert_type_id = alert_types.id,
    jsonb_to_record(variables) AS json(
      current_period_kwh float,
      previous_period_kwh float,
      current_period_co2 float,
      previous_period_co2 float,
      current_period_gbp float,
      previous_period_gbp float,
      previous_period_kwh_unadjusted float,
      tariff_has_changed boolean,
      pupils_changed boolean,
      floor_area_changed boolean
    )
  WHERE alert_types.class_name='AlertConfigurablePeriodStorageHeaterComparison'
), benchmark AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts
  JOIN alert_types ON alerts.alert_type_id = alert_types.id,
    jsonb_to_record(variables) AS data(solar_type text)
  WHERE alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
), additional AS (
  SELECT alert_generation_run_id, school_id, data.*
  FROM alerts
  JOIN alert_types ON alerts.alert_type_id = alert_types.id,
    jsonb_to_record(variables) AS data(activation_date date)
  WHERE alert_types.class_name='AlertAdditionalPrioritisationData'
), latest_runs AS (
  SELECT id
  FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY school_id ORDER BY created_at DESC) as row_num
    FROM alert_generation_runs
  ) AS ranked
  WHERE row_num = 1
)
SELECT latest_runs.id,
       additional.school_id,
       additional.activation_date,
       benchmark.solar_type,
       electricity.current_period_kwh AS electricity_current_period_kwh,
       electricity.previous_period_kwh AS electricity_previous_period_kwh,
       electricity.current_period_co2 AS electricity_current_period_co2,
       electricity.previous_period_co2 AS electricity_previous_period_co2,
       electricity.current_period_gbp AS electricity_current_period_gbp,
       electricity.previous_period_gbp AS electricity_previous_period_gbp,
       electricity.tariff_has_changed AS electricity_tariff_has_changed,
       gas.current_period_kwh AS gas_current_period_kwh,
       gas.previous_period_kwh AS gas_previous_period_kwh,
       gas.current_period_co2 AS gas_current_period_co2,
       gas.previous_period_co2 AS gas_previous_period_co2,
       gas.current_period_gbp AS gas_current_period_gbp,
       gas.previous_period_gbp AS gas_previous_period_gbp,
       gas.previous_period_kwh_unadjusted as gas_previous_period_kwh_unadjusted,
       gas.tariff_has_changed AS gas_tariff_has_changed,
       storage_heater.current_period_kwh AS storage_heater_current_period_kwh,
       storage_heater.previous_period_kwh AS storage_heater_previous_period_kwh,
       storage_heater.current_period_co2 AS storage_heater_current_period_co2,
       storage_heater.previous_period_co2 AS storage_heater_previous_period_co2,
       storage_heater.current_period_gbp AS storage_heater_current_period_gbp,
       storage_heater.previous_period_gbp AS storage_heater_previous_period_gbp,
       storage_heater.previous_period_kwh_unadjusted AS storage_heater_previous_period_kwh_unadjusted,
       storage_heater.tariff_has_changed AS storage_heater_tariff_has_changed,
       COALESCE(electricity.comparison_report_id, gas.comparison_report_id, storage_heater.comparison_report_id) AS comparison_report_id,
       electricity.pupils_changed OR gas.pupils_changed OR storage_heater.pupils_changed AS pupils_changed,
       electricity.floor_area_changed OR gas.floor_area_changed OR storage_heater.floor_area_changed AS floor_area_changed
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN benchmark ON latest_runs.id = benchmark.alert_generation_run_id
LEFT JOIN electricity ON latest_runs.id = electricity.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
  AND (electricity.comparison_report_id IS NULL OR electricity.comparison_report_id = gas.comparison_report_id)
LEFT JOIN storage_heater ON latest_runs.id = storage_heater.alert_generation_run_id
  AND (gas.comparison_report_id IS NULL OR gas.comparison_report_id = storage_heater.comparison_report_id)
  AND (electricity.comparison_report_id IS NULL
       OR electricity.comparison_report_id = storage_heater.comparison_report_id)
