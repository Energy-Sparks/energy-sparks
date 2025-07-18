SELECT latest_runs.id,
       data.*,
       additional.electricity_economic_tariff_changed_this_year
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      average_school_day_last_year_kw_per_floor_area float,
      average_school_day_last_year_kw float,
      exemplar_kw float,
      one_year_saving_versus_exemplar_gbp float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertElectricityPeakKWVersusBenchmark'
  ) AS data,
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(electricity_economic_tariff_changed_this_year boolean)
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
  ) AS additional,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id AND
  additional.alert_generation_run_id = latest_runs.id;
