-- This query is used to find data issues by looking for anomalies in validated electricity meter readings
--
-- Anomalies are defined as sudden changes in baseload, e.g. a large daily change or drop to zero.
-- This type of anomaly can be used to identify meter data issues or the installation of a solar array
--
-- The query does all of the baseload calculations from the underlying half-hourly data, applying alternate
-- rules depending on whether the meter is associated with solar panels (with either metered or estimated data)
--
-- The query is built from four CTEs that build on each other to fetch and calculate the baseload with the
-- final comparison done in the SELECT query at the end
--
-- It returns the id of the amr_validated_reading with the anomalous reading, along with the meter_id, reading_date
-- and the calculated baseload for that and the previous day.
--
-- The SQL is commented, but to summarise:
--
-- unnested_readings_with_index -
--   selects the amr_validated_readings, unnesting the 48 half-hourly readings so there is a row
--   per reading, it includes the index of the reading in the original array
--
-- unnested_readings_with_index_and_ranking
--   calculates an additional index for each half-hourly reading, lowest first. Either the original
--   array index or this order is used when calculating the baseload
--
-- daily_baseload
--   calculates the baseload, switching between two different methods depending on whether the
--   meter has a solar array
--
-- last_two_days_baseload
--   brings together each days readings with the day before
--
-- The final SELECT statement then selects from with_prev_day to identify the anomalies.
--
-- An anomaly is: a drop to near zero (0.0--0.01), where the previous day is not a negligible value. Or there has
-- just been a large drop in baseload (change by x5)

-- Join the amr_validated_readings to the meters table
WITH unnested_readings_with_index AS (
  SELECT
    amr.id AS id,
    amr.meter_id,
    amr.reading_date,
    -- creates a flag to indicate whether there is a solar array associated with the meter
    EXISTS (
      SELECT 1 FROM meter_attributes ma
      WHERE ma.meter_id = amr.meter_id
        AND (ma.attribute_type = 'solar_pv_mpan_meter_mapping' OR ma.attribute_type = 'solar_pv')
        AND ma.deleted_by_id IS NULL
        AND ma.replaced_by_id IS NULL
    ) AS has_solar,
    -- Convert kWh to kW
    t.val * 2.0 AS val_kw,
    -- original array index
    t.ordinality AS index
  FROM
    amr_validated_readings amr
    JOIN meters m ON amr.meter_id = m.id
    -- the cross join lateral joins the amr_validated_readings to each of their kwh readings
    -- the values are unnested with their index in the original array
    CROSS JOIN LATERAL UNNEST(amr.kwh_data_x48) WITH ORDINALITY AS t(val, ordinality)
  WHERE
    -- include previous day
    amr.reading_date >= CURRENT_DATE - INTERVAL '31 days'
     -- active electricity meters
    AND m.meter_type = 0
    AND m.active = true
),
unnested_readings_with_index_and_ranking AS (
  SELECT
    id,
    meter_id,
    reading_date,
    has_solar,
    val_kw,
    index,
    -- allows us to order the values by size, not just original index
    -- calculating this here seems to be more efficient than doing a self-join on the unnested_readings
    ROW_NUMBER() OVER (PARTITION BY meter_id, reading_date ORDER BY val_kw ASC) AS ranking
  FROM unnested_readings_with_index
),
daily_baseload AS (
  SELECT
    id,
    meter_id,
    reading_date,
    -- either calculate baseload from readings around midnight (if there are solar panels)
    -- or take lowest 8 half-hourly periods
    CASE
      WHEN has_solar
        THEN AVG(CASE WHEN index BETWEEN 1 AND 4 OR index BETWEEN 45 AND 48 THEN val_kw END)
      ELSE
        AVG(CASE WHEN ranking <= 8 THEN val_kw END)
    END AS selected_avg
  FROM unnested_readings_with_index_and_ranking
  GROUP BY id, meter_id, reading_date, has_solar
),
last_two_days_baseload AS (
  SELECT
    t1.id,
    t1.meter_id,
    t1.reading_date,
    t1.selected_avg AS today_baseload,
    t2.selected_avg AS previous_day_baseload
  FROM
    daily_baseload t1
    LEFT JOIN daily_baseload t2
      ON t1.meter_id = t2.meter_id
      AND t1.reading_date = t2.reading_date + INTERVAL '1 day'
  WHERE
    t1.reading_date >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT
  id,
  meter_id,
  reading_date,
  today_baseload,
  previous_day_baseload
FROM
  last_two_days_baseload
WHERE
  previous_day_baseload IS NOT NULL
  -- ignore if there is low use for the meter, e.g. if usage is always low or intermittent
  -- also ignores where the previous day usage was zero
  AND previous_day_baseload > 0.5
  AND (
    -- look for drops to near zero, not precisely zero
    (today_baseload >= 0 AND today_baseload < 0.01)
    OR
    -- look for large drops of any kind
    (previous_day_baseload >= today_baseload * 5)
  );
