SELECT latest_runs.id,
       usage.*,
       usage_previous_year.previous_out_of_hours_kwh,
       usage_previous_year.previous_out_of_hours_co2,
       usage_previous_year.previous_out_of_hours_gbpcurrent,
       additional.economic_tariff_changed_this_year
FROM
  (
    SELECT alert_generation_run_id, school_id, json.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS json(
      out_of_hours_kwh float,
      out_of_hours_co2 float,
      out_of_hours_gbpcurrent float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertOutOfHoursGasUsage'
  ) AS usage,
  (
    SELECT alert_generation_run_id, school_id,
      json.out_of_hours_kwh AS previous_out_of_hours_kwh,
      json.out_of_hours_co2 AS previous_out_of_hours_co2,
      json.out_of_hours_gbpcurrent AS previous_out_of_hours_gbpcurrent
    FROM alerts, alert_types, jsonb_to_record(variables) AS json(
      out_of_hours_kwh float,
      out_of_hours_co2 float,
      out_of_hours_gbpcurrent float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertOutOfHoursGasUsagePreviousYear'
  ) AS usage_previous_year,
  (
    SELECT alert_generation_run_id, json.gas_economic_tariff_changed_this_year AS economic_tariff_changed_this_year
    FROM alerts, alert_types, jsonb_to_record(variables) AS json(gas_economic_tariff_changed_this_year boolean)
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertAdditionalPrioritisationData'
  ) AS additional,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  usage.alert_generation_run_id = latest_runs.id AND
  usage_previous_year.alert_generation_run_id = latest_runs.id AND
  additional.alert_generation_run_id = latest_runs.id;
