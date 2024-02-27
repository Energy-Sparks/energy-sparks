SELECT latest_runs.id,
       data.*
FROM
  (
    SELECT alert_generation_run_id, school_id, data.*
    FROM alerts, alert_types, jsonb_to_record(variables) AS data(
      difference_percent float,
      difference_gbpcurrent float,
      difference_kwh float,
      name_of_current_period text,
      truncated_current_period text,
      name_of_previous_period text,
      pupils_changed boolean,
      current_period_pupils integer,
      previous_period_pupils integer,
      rating integer,
      tariff_has_changed boolean
    )
    WHERE alerts.alert_type_id = alert_types.id and
      alert_types.class_name='AlertPreviousYearHolidayComparisonElectricity'
  ) AS data,
  (
    SELECT DISTINCT ON (school_id) id
    FROM alert_generation_runs
    ORDER BY school_id, created_at DESC
  ) latest_runs
WHERE
  data.alert_generation_run_id = latest_runs.id;
