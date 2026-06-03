class X48Formatter

  def self.convert_dt_to_v_to_date_to_v_x48(start_date, end_date, dt_to_kwh, offset = false, default_datatype = nil)
    fail unless start_date.is_a?(Date) && end_date.is_a?(Date)

    missing_readings = []
    readings = Hash.new { |h, k| h[k] = Array.new(48, default_datatype) }
    (start_date..end_date).each do |date|
      dt = date.to_datetime
      (0..47).each do |idx|
        dt = self.advance_by_minutes(dt, 30) if offset
        if dt_to_kwh.key?(dt)
          readings[date][idx] = dt_to_kwh[dt]
        else
          missing_readings.push(dt)
        end
        dt = self.advance_by_minutes(dt, 30) unless offset
      end
    end
    {
      readings:         readings,
      missing_readings: missing_readings
    }
  end

  def self.advance_by_minutes(date, mins)
    date + Rational(mins*60, 86400)
  end
end
