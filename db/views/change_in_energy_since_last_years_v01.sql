SELECT latest_runs.id,
       energy.school_id,
       energy.previous_year_electricity_kwh,
       energy.current_year_electricity_kwh,
       energy.previous_year_electricity_co2,
       energy.current_year_electricity_co2,
       energy.previous_year_electricity_gbp,
       energy.current_year_electricity_gbp,

       energy.previous_year_gas_kwh,
       energy.current_year_gas_kwh,
       energy.previous_year_gas_co2,
       energy.current_year_gas_co2,
       energy.previous_year_gas_gbp,
       energy.current_year_gas_gbp,

       energy.previous_year_storage_heaters_kwh,
       energy.current_year_storage_heaters_kwh,
       energy.previous_year_storage_heaters_co2,
       energy.current_year_storage_heaters_co2,
       energy.previous_year_storage_heaters_gbp,
       energy.current_year_storage_heaters_gbp,

       energy.previous_year_solar_pv_kwh,
       energy.current_year_solar_pv_kwh,
       energy.previous_year_solar_pv_co2,
       energy.current_year_solar_pv_co2,
       energy.previous_year_solar_pv_gbp,
       energy.current_year_solar_pv_gbp,

       energy.solar_type
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

      previous_year_gas_kwh float,
      current_year_gas_kwh float,
      previous_year_gas_co2 float,
      current_year_gas_co2 float,
      previous_year_gas_gbp float,
      current_year_gas_gbp float,

      previous_year_storage_heaters_kwh float,
      current_year_storage_heaters_kwh float,
      previous_year_storage_heaters_co2 float,
      current_year_storage_heaters_co2 float,
      previous_year_storage_heaters_gbp float,
      current_year_storage_heaters_gbp float,

      previous_year_solar_pv_kwh float,
      current_year_solar_pv_kwh float,
      previous_year_solar_pv_co2 float,
      current_year_solar_pv_co2 float,
      previous_year_solar_pv_gbp float,
      current_year_solar_pv_gbp float,

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
