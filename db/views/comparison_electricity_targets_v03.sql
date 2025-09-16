WITH current_targets AS (
  SELECT school_targets.school_id,
         MAX(school_targets.start_date)
  FROM school_targets
  WHERE school_targets.start_date < now()
  GROUP BY school_id
),
totals AS (
  SELECT school_targets.id,
         SUM((consumption ->> 2)::float) AS current_year_kwh,
         SUM((consumption ->> 4)::float) AS current_year_target_kwh
  FROM school_targets, jsonb_array_elements(electricity_monthly_consumption) consumption
  WHERE (consumption ->> 5)::boolean = false
  GROUP BY school_targets.id
)
SELECT school_targets.school_id,
       -school_targets.electricity AS current_target,
       school_targets.start_date AS tracking_start_date,
       totals.*,
       ((totals.current_year_kwh - totals.current_year_target_kwh) / totals.current_year_target_kwh) AS current_year_percent_of_target_relative
FROM school_targets
JOIN totals ON totals.id = school_targets.id
JOIN current_targets ON current_targets.school_id = school_targets.school_id AND current_targets.max = school_targets.start_date
