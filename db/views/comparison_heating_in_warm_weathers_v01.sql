WITH gas AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    percent_of_annual_heating float,
    warm_weather_heating_days_all_days_kwh float,
    warm_weather_heating_days_all_days_co2 float,
    warm_weather_heating_days_all_days_gbpcurrent float,
    warm_weather_heating_days_all_days_days float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertSeasonalHeatingSchoolDays'
), storage_heaters AS (
  SELECT alert_generation_run_id, data.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS data(
    percent_of_annual_heating float,
    warm_weather_heating_days_all_days_kwh float,
    warm_weather_heating_days_all_days_co2 float,
    warm_weather_heating_days_all_days_gbpcurrent float,
    warm_weather_heating_days_all_days_days float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertSeasonalHeatingSchoolDaysStorageHeaters'
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
  COALESCE(gas.percent_of_annual_heating, storage_heaters.percent_of_annual_heating) as percent_of_annual_heating,
  COALESCE(gas.warm_weather_heating_days_all_days_kwh, storage_heaters.warm_weather_heating_days_all_days_kwh) as warm_weather_heating_days_all_days_kwh,
  COALESCE(gas.warm_weather_heating_days_all_days_co2, storage_heaters.warm_weather_heating_days_all_days_co2) as warm_weather_heating_days_all_days_co2,
  COALESCE(gas.warm_weather_heating_days_all_days_gbpcurrent, storage_heaters.warm_weather_heating_days_all_days_gbpcurrent) as warm_weather_heating_days_all_days_gbpcurrent,
  COALESCE(gas.warm_weather_heating_days_all_days_days, storage_heaters.warm_weather_heating_days_all_days_days) as warm_weather_heating_days_all_days_days
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
LEFT JOIN storage_heaters ON latest_runs.id = storage_heaters.alert_generation_run_id;
