WITH early AS (
  SELECT alert_generation_run_id, json.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS json(
    avg_week_start_time time,
    one_year_optimum_start_saving_gbpcurrent float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertHeatingComingOnTooEarly'
), optimum AS (
  SELECT alert_generation_run_id, json.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS json(
    average_start_time_hh_mm time,
    start_time_standard_devation float,
    rating float,
    regression_start_time float,
    optimum_start_sensitivity float,
    regression_r2 float
  )
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertOptimumStartAnalysis'
), additional AS (
  SELECT alert_generation_run_id, school_id, json.*
  FROM alerts, alert_types, jsonb_to_record(variables) AS json(gas_economic_tariff_changed_this_year boolean)
  WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
), latest_runs AS (
  SELECT DISTINCT ON (school_id) id
  FROM alert_generation_runs
  ORDER BY school_id, created_at DESC
)
SELECT latest_runs.id,
       additional.*,
       early.avg_week_start_time,
       early.one_year_optimum_start_saving_gbpcurrent,
       optimum.average_start_time_hh_mm,
       optimum.start_time_standard_devation,
       optimum.rating,
       optimum.regression_start_time,
       optimum.optimum_start_sensitivity,
       optimum.regression_r2
FROM latest_runs
JOIN additional ON latest_runs.id = additional.alert_generation_run_id
LEFT JOIN early ON latest_runs.id = early.alert_generation_run_id
LEFT JOIN optimum ON latest_runs.id = optimum.alert_generation_run_id;
