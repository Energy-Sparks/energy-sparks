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
  gas.percent_of_annual_heating,
  gas.warm_weather_heating_days_all_days_kwh,
  gas.warm_weather_heating_days_all_days_co2,
  gas.warm_weather_heating_days_all_days_gbpcurrent,
  gas.warm_weather_heating_days_all_days_days
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN gas ON latest_runs.id = gas.alert_generation_run_id
