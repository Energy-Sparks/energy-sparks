# type is the type of correction, original data = 'ORIG', a list of types (primary key/constaint) is held in AMR_TYPES
class OneDayAMRReading
  include Comparable
  include Logging

  attr_reader :date, :type, :substitute_date, :upload_datetime, :one_day_kwh, :kwh_data_x48

  def initialize(date, type, substitute_date, upload_datetime, kwh_data_x48) # rubocop:disable Metrics/AbcSize
    raise EnergySparksBadAMRDataTypeException, 'Unexpected nil AMR bad data type' if type.nil?
    raise EnergySparksBadAMRDataTypeException, "Unexpected AMR bad data type #{type}" unless AMR_TYPE_SET.include?(type)

    @date = date
    @upload_datetime = upload_datetime
    @type = type
    @substitute_date = substitute_date
    @kwh_data_x48 = kwh_data_x48

    valid = 0
    sum = 0.0
    has_nil = false

    @kwh_data_x48.each do |kwh|
      if kwh.nil?
        valid += 1
        has_nil = true
      elsif kwh.is_a?(Float) || kwh.is_a?(Integer)
        valid += 1
        sum += kwh
      end
    end

    if valid != 48
      raise EnergySparksBadAMRDataTypeException,
            "Error: expecting all 48 half hour kWh values to be float or integer (or nil) (valid: #{valid}, date: #{date})"
    end

    @one_day_kwh = has_nil ? nil : sum
  end

  def +(other)
    OneDayAMRReading.new(
      @date,
      'AGGR',
      nil,
      DateTime.now,
      AMRData.fast_add_x48_x_x48(@kwh_data_x48, other.kwh_data_x48)
    )
  end

  def self.zero_reading(date, type, value = 0.0)
    OneDayAMRReading.new(date, type, nil, DateTime.now, Array.new(48, value))
  end

  def self.scale(one_days_reading, scale_factor)
    OneDayAMRReading.new(
      one_days_reading.date,
      one_days_reading.type,
      one_days_reading.substitute_date,
      DateTime.now,
      AMRData.fast_multiply_x48_x_scalar(one_days_reading.kwh_data_x48, scale_factor)
    )
  end

  def kwh_halfhour(half_hour_index)
    @kwh_data_x48[half_hour_index]
  end

  def set_type(type)
    @type = type
  end

  def to_s
    date = @date.strftime('%d-%m-%Y')
    upload_datetime = @date.strftime('%d-%m-%Y %H:%M')
    sub_date = @substitute_date.nil? ? '' : @substitute_date.strftime('%d-%m-%Y')
    total = format('%4.1f', @one_day_kwh)
    [date, @type, total, upload_datetime, sub_date, @kwh_data_x48].flatten.join(',')
  end

  def <=>(other)
    other.class == self.class &&
      [date, type, substitute_date] <=> [other.date, other.type, other.substitute_date] &&
      one_day_kwh <=> other.one_day_kwh &&
      @kwh_data_x48 <=> other.kwh_data_x48
  end
end
