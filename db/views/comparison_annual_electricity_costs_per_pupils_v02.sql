SELECT latest_runs.id,
       data.*,
       additional.electricity_economic_tariff_changed_this_year
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      one_year_electricity_per_pupil_gbp float,
      one_year_electricity_per_pupil_kwh float,
      one_year_electricity_per_pupil_co2 float,
      last_year_gbp float,
      last_year_kwh float,
      last_year_co2 float,
      one_year_saving_versus_exemplar_gbpcurrent float
  )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertElectricityAnnualVersusBenchmark'
  ) AS data,
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      electricity_economic_tariff_changed_this_year boolean
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
  ) AS additional,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id
AND
  additional.alert_generation_run_id = latest_runs.id;
