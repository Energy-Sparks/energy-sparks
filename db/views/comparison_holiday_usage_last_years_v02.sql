SELECT latest_runs.id,
       data.*
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      last_year_holiday_gas_gbp float,
      last_year_holiday_electricity_gbp float,
      last_year_holiday_gas_gbpcurrent float,
      last_year_holiday_electricity_gbpcurrent float,
      last_year_holiday_gas_kwh_per_floor_area float,
      last_year_holiday_electricity_kwh_per_floor_area float,
      last_year_holiday_type text,
      last_year_holiday_start_date date,
      last_year_holiday_end_date date,
      holiday_start_date date
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertImpendingHoliday'
  ) AS data,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id;
