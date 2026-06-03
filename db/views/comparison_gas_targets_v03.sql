WITH current_targets AS (
  SELECT id
  FROM (SELECT school_targets.*, ROW_NUMBER() OVER (PARTITION BY school_id ORDER BY start_date DESC) AS rank
        FROM school_targets WHERE start_date < now()) ranked
  WHERE rank = 1
),
totals AS (
  SELECT school_targets.id,
         SUM((consumption ->> 2)::float) AS current_year_kwh,
         SUM((consumption ->> 3)::float) AS previous_year_kwh,
         SUM((consumption ->> 4)::float) AS current_year_target_kwh
  FROM school_targets, jsonb_array_elements(gas_monthly_consumption) consumption
  WHERE (consumption ->> 5)::boolean = false
  GROUP BY school_targets.id
)
SELECT school_targets.school_id,
       -school_targets.gas AS current_target,
       school_targets.start_date AS tracking_start_date,
       totals.*,
       ((totals.current_year_kwh - totals.previous_year_kwh) / totals.previous_year_kwh) AS previous_to_current_year_change
FROM school_targets
JOIN totals ON totals.id = school_targets.id
JOIN current_targets ON current_targets.id = school_targets.id
WHERE totals.previous_year_kwh > 0
