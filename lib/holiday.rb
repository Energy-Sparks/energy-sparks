# frozen_string_literal: true

class Holiday < SchoolDatePeriod
  attr_accessor :type, :academic_year # :easter, :xmas, autumn_halfterm etc.  # e.g. 2018..2019

  def initialize(type, name, start_date, end_date, academic_year)
    start_date = roll_start_date_back_to_sunday(start_date, type)
    end_date = roll_end_date_forward_to_saturday(end_date, type)
    name = Holidays.holiday_name(middle_date(start_date, end_date)) if name.nil? || name == 'No title'
    super(:holiday, name, start_date, end_date)
    @type = type
    @academic_year = academic_year
    raise EnergySparksNoMeterDataAvailableForFuelType, 'Start date after end date' if start_date > end_date
  end

  def number_weekdays
    d = 0
    (start_date..end_date).each do |date|
      d += 1 if date.wday.between?(1, 5)
    end
    d
  end

  def middle_date(start_date = @start_date, end_date = @end_date)
    start_date + ((end_date - start_date) / 2).to_i
  end

  def to_s
    "#{super} #{@type} #{"#{@academic_year.first}/#{@academic_year.last}" unless @academic_year.nil?}"
  end

  def translation_type
    # set_holiday_types overwrites the type using Holidays.holiday_type but only does so for @holidays and not
    # @additional_holidays so Mayday doesn't get set as it is classed as additional being a bank holiday
    Holidays.holiday_type(middle_date)
  end

  private

  def roll_start_date_back_to_sunday(start_date, type)
    return start_date - 1 if start_date.monday? && roll?(type)

    start_date
  end

  def roll_end_date_forward_to_saturday(end_date, type)
    return end_date + 1 if end_date.friday? && roll?(type)

    end_date
  end

  def roll?(type)
    %i[inset_day_in_school bank_holiday].exclude?(type)
  end
end
