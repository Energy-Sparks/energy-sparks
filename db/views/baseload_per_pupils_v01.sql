SELECT latest_runs.id,
       additional.school_id,
       baseload.*,
       additional.electricity_economic_tariff_changed_this_year
FROM
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, json_to_record(variables) AS data(
      average_baseload_last_year_kw float,
      average_baseload_last_year_gbp float,
      one_year_baseload_per_pupil_kw float,
      annual_baseload_percent float,
      one_year_saving_versus_exemplar_gbp float
    )
    WHERE alert_type_id=1
  ) AS baseload,
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, json_to_record(variables) AS data(electricity_economic_tariff_changed_this_year boolean)
    WHERE alert_type_id=59
  ) AS additional,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  baseload.alert_generation_run_id = latest_runs.id AND
  additional.alert_generation_run_id = latest_runs.id;
