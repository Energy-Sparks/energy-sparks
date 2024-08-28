# frozen_string_literal: true

class AverageCalculator
  SCHOOL_TYPES = %i[primary secondary special].freeze

  def calculate_school_averages(school, fuel_type)
    # @school_type_samples ||= Hash.new {|hash, school_type| hash[school_type] = Hash.new{|h, fuel_type| h[fuel_type] = 0 }}

    # debugger
    school_type = school.school_type.to_sym
    return unless SCHOOL_TYPES.include?(school_type)

    meter = school.aggregate_meter(fuel_type)

    return if meter.nil? || meter.amr_data.days < 50

    return if fuel_type == :gas && meter.amr_data.days < 350 # degreeday adjustment wont work otherwise

    # only do stats on one benchmark type, as count should be same for the other e.g. :exemplar
    # @school_type_samples[school_type][fuel_type] += 1 if type == :benchmark

    end_date = meter.amr_data.end_date
    start_date = [end_date - 365, meter.amr_data.start_date].max
    {
      school_name: school.name,
      school_type:,
      monthly_data: calculate_monthly_average_profiles(school, meter, start_date, end_date)
    }
  end

  def calculate_monthly_average_profiles(school, meter, start_date, end_date)
    collated_data = collate_data(school, meter, start_date, end_date)
    factor = normalising_factor(school, meter, start_date, end_date)
    average_data(collated_data, factor)
  end

  def normalising_factor(school, meter, start_date, end_date)
    if meter.fuel_type == :electricity
      1.0 / school.number_of_pupils(start_date, end_date)
    else
      degree_days_to_average_factor(school, start_date, end_date) / school.floor_area(start_date, end_date)
    end
  end

  def collate_data(school, meter, start_date, end_date)
    data = { schoolday: {}, holiday: {}, weekend: {} }

    (start_date..end_date).each do |date|
      daytype = school.holidays.day_type(date)
      month = month_or_holiday(school, date)
      data[daytype][month] ||= []
      data[daytype][month].push(meter.amr_data.days_kwh_x48(date))
    end

    data
  end

  def month_or_holiday(school, date)
    if school.holidays.day_type(date) == :holiday
      holiday_type = Holidays.holiday_type(date)
      holiday_type = AverageSchoolCalculator.remap_low_sample_holiday(holiday_type)
      raise "Unknown holiday type for #{school.name} #{date}" if holiday_type.nil?

      holiday_type
    else
      date.month
    end
  end

  def average_data(collated_data, factor)
    data = { schoolday: {}, holiday: {}, weekend: {} }

    collated_data.each do |daytype, months|
      months.each do |month, amr_data_x48_x30|
        data[daytype][month] =
          AMRData.fast_multiply_x48_x_scalar(AMRData.fast_average_multiple_x48(amr_data_x48_x30), factor)
      end
    end

    data
  end
end
