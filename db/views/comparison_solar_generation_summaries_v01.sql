SELECT latest_runs.id,
       solar_generation.*
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      annual_electricity_kwh float,
      annual_mains_consumed_kwh float,
      annual_solar_pv_kwh float,
      annual_exported_solar_pv_kwh float,
      annual_solar_pv_consumed_onsite_kwh float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertSolarGeneration'
  ) AS solar_generation,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  solar_generation.alert_generation_run_id = latest_runs.id;
