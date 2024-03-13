SELECT latest_runs.id,
       energy.*,
       gas.temperature_adjusted_previous_year_kwh,
       gas.temperature_adjusted_percent

FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      previous_year_gas_kwh float,
      current_year_gas_kwh float,
      previous_year_gas_co2 float,
      current_year_gas_co2 float,
      previous_year_gas_gbp float,
      current_year_gas_gbp float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
  ) AS energy,
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      temperature_adjusted_previous_year_kwh float,
      temperature_adjusted_percent float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertGasAnnualVersusBenchmark'
  ) AS gas,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  energy.alert_generation_run_id = latest_runs.id AND
  gas.alert_generation_run_id = latest_runs.id;

