SELECT latest_runs.id,
       enba.school_id,
       enba.previous_year_electricity_kwh,
       enba.current_year_electricity_kwh,
       enba.previous_year_electricity_co2,
       enba.current_year_electricity_co2,
       enba.previous_year_electricity_gbp,
       enba.current_year_electricity_gbp,
       enba.solar_type
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      previous_year_electricity_kwh float,
      current_year_electricity_kwh float,
      previous_year_electricity_co2 float,
      current_year_electricity_co2 float,
      previous_year_electricity_gbp float,
      current_year_electricity_gbp float,
      solar_type text
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
  ) AS enba,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  enba.alert_generation_run_id = latest_runs.id;
