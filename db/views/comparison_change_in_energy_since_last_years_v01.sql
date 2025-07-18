SELECT latest_runs.id,
       energy.school_id,

       energy.current_year_electricity_kwh AS electricity_current_period_kwh,
       energy.previous_year_electricity_kwh AS electricity_previous_period_kwh,
       energy.current_year_electricity_co2 AS electricity_current_period_co2,
       energy.previous_year_electricity_co2 AS electricity_previous_period_co2,
       energy.current_year_electricity_gbp AS electricity_current_period_gbp,
       energy.previous_year_electricity_gbp AS electricity_previous_period_gbp,

       energy.current_year_gas_kwh AS gas_current_period_kwh,
       energy.previous_year_gas_kwh AS gas_previous_period_kwh,
       energy.current_year_gas_co2 AS gas_current_period_co2,
       energy.previous_year_gas_co2 AS gas_previous_period_co2,
       energy.current_year_gas_gbp AS gas_current_period_gbp,
       energy.previous_year_gas_gbp AS gas_previous_period_gbp,

       energy.current_year_storage_heaters_kwh AS storage_heater_current_period_kwh,
       energy.previous_year_storage_heaters_kwh AS storage_heater_previous_period_kwh,
       energy.current_year_storage_heaters_co2 AS storage_heater_current_period_co2,
       energy.previous_year_storage_heaters_co2 AS storage_heater_previous_period_co2,
       energy.current_year_storage_heaters_gbp AS storage_heater_current_period_gbp,
       energy.previous_year_storage_heaters_gbp AS storage_heater_previous_period_gbp,

       energy.current_year_solar_pv_kwh AS solar_pv_current_period_kwh,
       energy.previous_year_solar_pv_kwh AS solar_pv_previous_period_kwh,
       energy.current_year_solar_pv_co2 AS solar_pv_current_period_co2,
       energy.previous_year_solar_pv_co2 AS solar_pv_previous_period_co2,

       additional.electricity_economic_tariff_changed_this_year AS electricity_tariff_has_changed,
       additional.gas_economic_tariff_changed_this_year AS gas_tariff_has_changed,

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

      solar_type text
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertEnergyAnnualVersusBenchmark'
  ) AS energy,
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      electricity_economic_tariff_changed_this_year boolean,
      gas_economic_tariff_changed_this_year boolean
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
