-- This query is used to find data issues by looking for anomalies in validated gas meter readings
--
-- Anomalies are defined as sudden increases in daily usage
-- This type of anomaly might be due to a unit error when loading data, e.g. treating kwh as cubic meters
--
-- However there are also plenty of legitimate cases where gas usage will suddenly increase, e.g:
--
-- Heating is switched on after a holiday or weekend
-- Heating is switched on in the winter, or a particularly cold day
--
-- The report tries to reduce false positives by only comparing usage between the same day of the week
-- (e.g. Monday with Monday) and within similar calendar periods (e.g. within holidays or term times).
--
-- It also takes into account temperatures by looking at the difference in degree days between the days
-- being compared. A small change in degree days but a large change in usage is considered to be unusual.
--
-- The view is made of a a CTE that combines the validated readings with information from the schools calendar
-- and associated weather station, to calculate the average temperature and degree days for each day
--
-- This is then used to do the actual comparisons.
--
WITH readings_with_temperature_and_event AS (
  SELECT
    amr.id as id,
    amr.meter_id,
    amr.reading_date,
    amr.one_day_kwh,
    ROUND(AVG(temp), 2) as average_temperature,
    -- calculates heating degree days using standard base temp for uk
    ROUND(GREATEST(15.5 - AVG(temp), 0), 2) AS heating_degree_days,
    calendar_events.calendar_event_type_id
  FROM
    amr_validated_readings amr
    JOIN meters on amr.meter_id = meters.id
    JOIN schools on meters.school_id = schools.id
    JOIN calendars on schools.calendar_id = calendars.id
    JOIN calendar_events on calendars.id = calendar_events.calendar_id
      AND amr.reading_date BETWEEN calendar_events.start_date AND calendar_events.end_date
    JOIN calendar_event_types ON calendar_events.calendar_event_type_id = calendar_event_types.id
    JOIN weather_stations on schools.weather_station_id = weather_stations.id
    JOIN weather_observations on weather_stations.id = weather_observations.weather_station_id
      AND weather_observations.reading_date = amr.reading_date
    -- joins each validated reading with the half-hourly temperature data
    -- the aggregate functions in the SELECT calculate the averages and heating degree days
    JOIN LATERAL UNNEST(weather_observations.temperature_celsius_x48) AS temp ON TRUE
  WHERE
    -- a 60 days of data plus 7 days to allow comparisons
    amr.reading_date >= CURRENT_DATE - INTERVAL '67 days'
    -- exclude inset days and bank holidays to avoid having multiple calendar events
    -- per amr_validated_reading. Just want to check terms/holidays
  AND
    calendar_event_types.inset_day = false
  AND
    calendar_event_types.bank_holiday = false
  AND
    meters.active = true
  AND
    meters.meter_type = 1 -- only active gas meters
  GROUP BY amr.id, amr.reading_date, calendar_events.calendar_event_type_id
)
SELECT
 today.id,
 today.meter_id,
 today.reading_date,
 today.one_day_kwh as today_kwh,
 today.average_temperature as today_temperature,
 today.heating_degree_days as today_degree_days,
 previous_day.reading_date as previous_reading_date,
 previous_day.one_day_kwh as previous_kwh,
 previous_day.average_temperature as previous_temperature,
 previous_day.heating_degree_days as previous_degree_days,
 today.calendar_event_type_id
FROM
 readings_with_temperature_and_event AS previous_day
 LEFT JOIN readings_with_temperature_and_event AS today
  ON today.meter_id = previous_day.meter_id
  AND today.reading_date = previous_day.reading_date + INTERVAL '7 days'
WHERE
 previous_day.one_day_kwh is not null
AND
 -- only compare days for the same type of calendar event, e.g. holidays with holidays
 previous_day.calendar_event_type_id = today.calendar_event_type_id
AND
 -- ignore period when there was no usage, as likely just heating was off
 previous_day.one_day_kwh > 0.0
AND
 -- we use 10 here as the m3 -> kwh comparison is around x10/11
 today.one_day_kwh > 10 * previous_day.one_day_kwh
AND
 -- exclude days where there is a larger change in temperature and we might expect
 -- gas usage to have increased over a week
 ABS(today.heating_degree_days -  previous_day.heating_degree_days) < 2.0;
