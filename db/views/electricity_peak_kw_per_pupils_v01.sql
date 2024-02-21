SELECT latest_runs.id,
       additional.school_id,
       baseload.*,
       additional.electricity_economic_tariff_changed_this_year
FROM
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      average_school_day_last_year_kw_per_floor_area float,
      average_school_day_last_year_kw float,
      exemplar_kw float,
      saving_if_match_exemplar_gbp float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertElectricityPeakKWVersusBenchmark'
  ) AS baseload,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  baseload.alert_generation_run_id = latest_runs.id AND
  additional.alert_generation_run_id = latest_runs.id;
