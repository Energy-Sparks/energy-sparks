# originally amr_data was inherited from half_hourly_data which was a hash to 48 x halfhourly readings
# to better represent whether the data has been artificially created as a result of bad or missing
# data OneDayAMRReading replaces the 48 x halfhourly readings
# type is the type of correction, original data = 'ORIG', a list of types (primary key/constaint) is held in AMR_TYPES
class OneDayAMRReading
  include Comparable
  include Logging

  attr_reader :meter_id, :date, :type, :substitute_date, :upload_datetime
  attr_reader :one_day_kwh, :kwh_data_x48

  def initialize(meter_id, date, type, substitute_date, upload_datetime, kwh_data_x48, nils_valid = true)
    check_type(type)
    @meter_id = meter_id.to_s
    @date = date
    @upload_datetime = upload_datetime
    @type = type
    @substitute_date = substitute_date
    @kwh_data_x48 = kwh_data_x48
    valid = validate_data(nils_valid)
    if valid != 48
      raise EnergySparksBadAMRDataTypeException, "Error: expecting all 48 half hour kWh values to be float or integer (or nil) (valid: #{valid}, meter_id: #{meter_id}, date: #{date})"
    end
    @one_day_kwh = (nils_valid && kwh_data_x48.any?(&:nil?)) ? nil : kwh_data_x48.inject(:+)
  end

  def +(other)
    OneDayAMRReading.new(
      @meter_id,
      @date,
      'AGGR',
      nil,
      DateTime.now,
      AMRData.fast_add_x48_x_x48(@kwh_data_x48, other.kwh_data_x48)
    )
  end

  def self.zero_reading(id, date, type, value = 0.0)
    OneDayAMRReading.new(id, date, type, nil, DateTime.now, Array.new(48, value))
  end

  def self.scale(one_days_reading, scale_factor)
    scaled = OneDayAMRReading.new(
      one_days_reading.meter_id,
      one_days_reading.date,
      one_days_reading.type,
      one_days_reading.substitute_date,
      DateTime.now,
      AMRData.fast_multiply_x48_x_scalar(one_days_reading.kwh_data_x48, scale_factor)
    )
    scaled
  end

  def kwh_halfhour(half_hour_index)
    @kwh_data_x48[half_hour_index]
  end

  def set_kwh_halfhour(half_hour_index, kwh)
    @kwh_data_x48[half_hour_index] = kwh
    @one_day_kwh = kwh_data_x48.inject(:+)
  end

  def set_days_kwh_x48(days_kwh_data_x48)
    @kwh_data_x48 = days_kwh_data_x48
    @one_day_kwh = days_kwh_data_x48.inject(:+)
  end

  def set_type(type)
    @type = type
  end

  def check_type(type)
    if type.nil?
      raise EnergySparksBadAMRDataTypeException.new('Unexpected nil AMR bad data type')
    elsif !self.class.amr_types.key?(type)
      raise EnergySparksBadAMRDataTypeException.new("Unexpected AMR bad data type #{type}")
    end
  end

  def set_meter_id(meter_id)
    @meter_id = meter_id
  end

  def to_s
    date = @date.strftime('%d-%m-%Y')
    upload_datetime = @date.strftime('%d-%m-%Y %H:%M')
    sub_date = @substitute_date.nil? ? '' : @substitute_date.strftime('%d-%m-%Y')
    total = sprintf('%4.1f', @one_day_kwh)
    [date, @type, total, upload_datetime, sub_date, @kwh_data_x48].flatten.join(',')
  end

  def validate_data(nils_valid = false)
    return 0 if !@kwh_data_x48.is_a?(Array)
    data_count = @kwh_data_x48.count do |kwh|
      if nils_valid
        kwh.nil? || kwh.is_a?(Float) || kwh.is_a?(Integer)
      else
        kwh.is_a?(Float) || kwh.is_a?(Integer)
      end
    end
    if data_count != 48
      logger.info "Incomplete AMR data expecting 48 readings, got #{data_count} for date #{@date}"
      logger.info @kwh_data_x48
    end
    data_count
  end

  def <=>(other)
    other.class == self.class &&
    [meter_id, date, type, substitute_date] <=> [other.meter_id, other.date, other.type, other.substitute_date] &&
    one_day_kwh <=> other.one_day_kwh &&
    @kwh_data_x48 <=> other.kwh_data_x48
  end
end
