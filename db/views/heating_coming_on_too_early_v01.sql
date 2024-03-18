SELECT latest_runs.id,
       early.avg_week_start_time,
       early.one_year_optimum_start_saving_gbpcurrent,
       optimum.*,
       additional.gas_economic_tariff_changed_this_year
FROM
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      avg_week_start_time time,
      one_year_optimum_start_saving_gbpcurrent float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertHeatingComingOnTooEarly'
  ) AS early,
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      average_start_time_hh_mm time,
      start_time_standard_devation float,
      rating float,
      regression_start_time float,
      optimum_start_sensitivity float,
      regression_r2 float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertOptimumStartAnalysis'
  ) AS optimum,
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(gas_economic_tariff_changed_this_year boolean)
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
  ) AS additional,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  early.alert_generation_run_id = latest_runs.id AND
  optimum.alert_generation_run_id = latest_runs.id AND
  additional.alert_generation_run_id = latest_runs.id;
