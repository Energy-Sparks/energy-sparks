# type is the type of correction, original data = 'ORIG', a list of types (primary key/constaint) is held in AMR_TYPES
class OneDayAMRReading
  include Comparable
  include Logging

  attr_reader :date, :type, :substitute_date, :upload_datetime, :one_day_kwh, :kwh_data_x48

  ZERO_X48 = Array.new(48, 0.0).freeze

  def initialize(date, type, substitute_date, upload_datetime, kwh_data_x48)
    unless AMR_TYPE_SET.include?(type)
      raise EnergySparksBadAMRDataTypeException,
            "Unexpected AMR bad data type #{type.inspect}"
    end
    unless kwh_data_x48.length == 48
      raise EnergySparksBadAMRDataTypeException,
            "Expecting 48 readings, got #{kwh_data_x48.length}"
    end

    @date = date
    @upload_datetime = upload_datetime
    @type = type
    @substitute_date = substitute_date
    @kwh_data_x48 = kwh_data_x48

    sum = 0.0
    has_nil = false

    kwh_data_x48.each do |kwh|
      if kwh.nil?
        has_nil = true
      else
        sum += kwh
      end
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

  def self.zero_reading(date, type)
    OneDayAMRReading.new(date, type, nil, DateTime.now, ZERO_X48)
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
    upload_datetime = @upload_datetime.strftime('%d-%m-%Y %H:%M')
    sub_date = @substitute_date.nil? ? '' : @substitute_date.strftime('%d-%m-%Y')
    total = format('%4.1f', @one_day_kwh)
    [date, @type, total, upload_datetime, sub_date, @kwh_data_x48].flatten.join(',')
  end

  def <=>(other)
    other.instance_of?(self.class) &&
      [date, type, substitute_date] <=> [other.date, other.type, other.substitute_date] &&
      one_day_kwh <=> other.one_day_kwh &&
      @kwh_data_x48 <=> other.kwh_data_x48
  end
end
