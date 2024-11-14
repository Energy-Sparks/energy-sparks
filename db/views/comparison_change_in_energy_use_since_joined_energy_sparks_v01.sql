SELECT latest_runs.id,
       energy.school_id,
       additional.activation_date as activation_date,

       energy.current_year_electricity_kwh AS electricity_current_period_kwh,
       energy.activationyear_electricity_kwh AS electricity_previous_period_kwh,
       energy.current_year_electricity_co2 AS electricity_current_period_co2,
       energy.activationyear_electricity_co2 AS electricity_previous_period_co2,
       energy.current_year_electricity_gbp AS electricity_current_period_gbp,
       energy.activationyear_electricity_gbp AS electricity_previous_period_gbp,

       energy.current_year_gas_kwh AS gas_current_period_kwh,
       energy.activationyear_gas_kwh AS gas_previous_period_kwh,
       energy.current_year_gas_co2 AS gas_current_period_co2,
       energy.activationyear_gas_co2 AS gas_previous_period_co2,
       energy.current_year_gas_gbp AS gas_current_period_gbp,
       energy.activationyear_gas_gbp AS gas_previous_period_gbp,

       energy.current_year_storage_heaters_kwh AS storage_heater_current_period_kwh,
       energy.activationyear_storage_heaters_kwh AS storage_heater_previous_period_kwh,
       energy.current_year_storage_heaters_co2 AS storage_heater_current_period_co2,
       energy.activationyear_storage_heaters_co2 AS storage_heater_previous_period_co2,
       energy.current_year_storage_heaters_gbp AS storage_heater_current_period_gbp,
       energy.activationyear_storage_heaters_gbp AS storage_heater_previous_period_gbp,

       -- the alert puts text in these fields when there is limited or not enough data
       -- rename the columns as we're only using them to access those notes not the
       -- values which we calculate dynamically.
       energy.activationyear_electricity_kwh_relative_percent AS activationyear_electricity_note,
       energy.activationyear_gas_kwh_relative_percent AS activationyear_gas_note,
       energy.activationyear_storage_heaters_kwh_relative_percent AS activationyear_storage_heater_note,

       energy.solar_type
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      activationyear_electricity_kwh float,
      current_year_electricity_kwh float,
      activationyear_electricity_co2 float,
      current_year_electricity_co2 float,
      activationyear_electricity_gbp float,
      current_year_electricity_gbp float,

      activationyear_gas_kwh float,
      current_year_gas_kwh float,
      activationyear_gas_co2 float,
      current_year_gas_co2 float,
      activationyear_gas_gbp float,
      current_year_gas_gbp float,

      activationyear_storage_heaters_kwh float,
      current_year_storage_heaters_kwh float,
      activationyear_storage_heaters_co2 float,
      current_year_storage_heaters_co2 float,
      activationyear_storage_heaters_gbp float,
      current_year_storage_heaters_gbp float,

      activationyear_electricity_kwh_relative_percent text,
      activationyear_gas_kwh_relative_percent text,
      activationyear_storage_heaters_kwh_relative_percent text,

      solar_type text
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
  ) AS energy,
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      activation_date date
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
  ) AS additional,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  energy.alert_generation_run_id = latest_runs.id AND
  additional.alert_generation_run_id = latest_runs.id;
