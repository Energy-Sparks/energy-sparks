class TargetAttributes
  attr_reader :attributes
  def initialize(meter)
    @attributes = nil
    if meter.target_set?
      @attributes = meter.target_attributes.sort { |a, b| a[:start_date] <=> b[:start_date] }.uniq
    end
  end

  def table
    return [[]] unless target_set?

    @attributes.map { |t| [t[:start_date], t[:target]] }
  end

  def target_set?
    !@attributes.nil?
  end

  def target_date_ranges
    @target_date_ranges ||= convert_target_date_ranges
  end

  def average_target(start_date, end_date)
    return Float::NAN unless target_set?

    weighted_values = target_date_ranges.map do |target_range, value|
      [
        overlap_days(start_date, end_date, target_range.first, target_range.last) * 1.0,
        value
      ]
    end
    sumproduct = weighted_values.map{ |(a,b)| a * b }.sum
    sumproduct / weighted_values.transpose[0].sum
  end

  def target(date)
    return Float::NAN unless target_set?

    # don't use date_range.include? or cover? as 500 times slower than:
    target_date_ranges.select{ |date_range, _target| date >= date_range.first && date <= date_range.last }.values[0]
  end

  def first_target_date
    return nil unless target_set?

    @attributes[0][:start_date]
  end

  private

  def overlap_days(sd1, ed1, sd2, ed2)
    [[ed1, ed2].min - [sd1, sd2].max + 1, 0].max
  end

  def convert_target_date_ranges
    return {} unless target_set?

    h = {}
    h[Date.new(2000, 1, 1)..(attributes[0][:start_date] - 1)] = 1.0
    last_index = attributes.length - 1
    (0...last_index).each do |interim_index|
      h[attributes[interim_index][:start_date]..attributes[interim_index+1][:start_date]] = attributes[interim_index][:target]
    end
    h[attributes[last_index][:start_date]..Date.new(2050, 1, 1)] = attributes[last_index][:target]
    h
  end
end
