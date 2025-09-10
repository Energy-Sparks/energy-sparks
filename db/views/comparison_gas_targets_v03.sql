WITH totals AS (
  SELECT school_targets.school_id,
         -school_targets.gas as current_target,
         max(school_targets.start_date) AS tracking_start_date,
         sum((consumption ->> 2)::float) AS current_year_kwh,
         sum((consumption ->> 4)::float) AS current_year_target_kwh
  FROM school_targets, jsonb_array_elements(gas_monthly_consumption) consumption
  WHERE school_targets.start_date < now()
  GROUP BY school_targets.school_id, school_targets.gas
)
SELECT totals.*, ((totals.current_year_kwh - totals.current_year_target_kwh) / totals.current_year_target_kwh) AS current_year_percent_of_target_relative
FROM totals
