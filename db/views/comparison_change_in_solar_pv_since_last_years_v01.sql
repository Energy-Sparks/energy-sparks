SELECT latest_runs.id,
       versus_benchmark.school_id,
       versus_benchmark.previous_year_solar_pv_kwh,
       versus_benchmark.current_year_solar_pv_kwh,
       versus_benchmark.previous_year_solar_pv_co2,
       versus_benchmark.current_year_solar_pv_co2,
       versus_benchmark.solar_type
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      previous_year_solar_pv_kwh float,
      current_year_solar_pv_kwh float,
      previous_year_solar_pv_co2 float,
      current_year_solar_pv_co2 float,
      solar_type text
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
  ) AS versus_benchmark,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  versus_benchmark.alert_generation_run_id = latest_runs.id;
