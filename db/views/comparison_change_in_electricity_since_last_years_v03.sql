SELECT latest_runs.id,
       energy.school_id,
       energy.previous_year_electricity_kwh AS previous_year_kwh,
       energy.current_year_electricity_kwh AS current_year_kwh,
       energy.previous_year_electricity_co2 AS previous_year_co2,
       energy.current_year_electricity_co2 AS current_year_co2,
       energy.previous_year_electricity_gbpcurrent AS previous_year_gbp,
       energy.current_year_electricity_gbpcurrent AS current_year_gbp,
       energy.solar_type
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      previous_year_electricity_kwh float,
      current_year_electricity_kwh float,
      previous_year_electricity_co2 float,
      current_year_electricity_co2 float,
      previous_year_electricity_gbpcurrent float,
      current_year_electricity_gbpcurrent float,
      solar_type text
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
  ) AS energy,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  energy.alert_generation_run_id = latest_runs.id;
