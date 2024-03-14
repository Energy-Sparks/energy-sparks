SELECT latest_runs.id,
  data.*,
  additional.gas_economic_tariff_changed_this_year
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      schoolday_open_percent float,
      schoolday_closed_percent float,
      holidays_percent float,
      weekends_percent float,
      community_percent float,
      community_gbp float,
      out_of_hours_gbp float,
      potential_saving_gbp float
    )
    WHERE alerts.alert_type_id = alert_types.id and alert_types.class_name='AlertOutOfHoursGasUsage'
  ) AS data,
  (
    SELECT alert_generation_run_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
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
  data.alert_generation_run_id = latest_runs.id AND
  additional.alert_generation_run_id = latest_runs.id;

