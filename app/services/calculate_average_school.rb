# frozen_string_literal: true

class CalculateAverageSchool
  SCHOOL_TYPES = %i[primary secondary special].freeze # missing mixed?
  RANGES = {
    average: 0.4..0.6,
    benchmark: 0.2..0.4,
    exemplar: 0.1..0.25
  }.freeze
  FUEL_TYPES = %i[electricity gas].freeze

  # @return [Hash<Hash<Hash<Hash<Array>>>>]
  #   { electricity: { primary: { schoolday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                                            ..., },
  #                                 holiday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                                            ... },
  #                                 weekend: { month1 => array_of_averages_for_48_half_hour_periods,
  #                                            ... } } } }
  def self.perform(logger: Rails.logger)
    calc = new(logger)
    averages = FUEL_TYPES.index_with { {} }
    by_school_type = calc.calculate_averages_by_school_type
    FUEL_TYPES.each do |fuel_type|
      RANGES.each_key do |type|
        averages[fuel_type][type] =
          calc.average_by_type_within_rank_range(by_school_type[fuel_type], RANGES[type], fuel_type)
      end
    end
    averages
  end

  def initialize(logger)
    @school_type_samples = {}
    @logger = logger
  end

  # @return [Hash<Hash<Array<Hash<Array>>>>]
  #   { electricity: { primary: [{ schoolday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                                             ..., },
  #                                  holiday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                                             ... },
  #                                  weekend: { month1 => array_of_averages_for_48_half_hour_periods,
  #                                             ... } }]
  def calculate_averages_by_school_type
    by_school_type = Hash.new do |h1, fuel_type|
      h1[fuel_type] = Hash.new do |h2, school_type|
        h2[school_type] = []
      end
    end
    db_school_generator do |school|
      FUEL_TYPES.each do |fuel_type|
        school_data = calculate_school_average(school, fuel_type)
        by_school_type[fuel_type][school.school_type.to_sym] << school_data if school_data
      end
    end
    by_school_type
  end

  # @return [Hash<Hash<Hash<Array>>>]
  #   { primary: { schoolday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                             ..., },
  #                  holiday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                             ... },
  #                  weekend: { month1 => array_of_averages_for_48_half_hour_periods,
  #                             ... } }
  def average_by_type_within_rank_range(by_school_type, rank_range, fuel_type)
    averages = Hash.new do |h1, school_type|
      h1[school_type] = Hash.new do |h2, day_type|
        h2[day_type] = Hash.new do |h3, month|
          h3[month] = []
        end
      end
    end
    by_school_type.each do |school_type, school_data_array|
      group_by_half_hour(school_data_array).each do |day_type, month_data|
        month_data.each do |month, half_hour_data|
          half_hour_data.each do |half_hour, hh_kwh_x_n|
            sample_range = index_range_from_rank_range(hh_kwh_x_n.length, rank_range)
            to_average = hh_kwh_x_n.sort[sample_range]
            next if to_average.blank?

            averages[school_type][day_type][month][half_hour] = (to_average.sum / to_average.length).round(6)
          end
        end
      end
      averages[school_type][:samples] = @school_type_samples[school_type][fuel_type]
    end
    averages
  end

  private

  def group_by_half_hour(school_data_array)
    by_half_hour = Hash.new do |h1, day_type|
      h1[day_type] = Hash.new do |h2, month|
        h2[month] = Hash.new do |h3, half_hour|
          h3[half_hour] = []
        end
      end
    end
    school_data_array.each do |school_data|
      school_data.each do |day_type, month_data|
        months_or_holidays = day_type == :holiday ? Holidays::MAIN_HOLIDAY_TYPES : 1..12
        months_or_holidays.each do |month|
          (0..47).each do |half_hour|
            amr_x48 = month_data[month]
            next if amr_x48.nil?

            by_half_hour[day_type][month][half_hour] << amr_x48[half_hour]
          end
        end
      end
    end
    by_half_hour
  end

  def db_school_generator
    School.data_enabled.order(:name).each do |school|
      @logger.info("loading #{school.slug}")
      yield AggregateSchoolService.new(school).aggregate_school
    end
  end

  # @param school [MeterCollection]
  # @param fuel_type [Symbol]
  # @return [Hash]
  #   { schoolday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                            ..., },
  #       holiday: { month1 => array_of_averages_for_48_half_hour_periods,
  #                            ... },
  #       weekend: { month1 => array_of_averages_for_48_half_hour_periods,
  #                            ... } }
  def calculate_school_average(school, fuel_type)
    (meter = get_meter(school, fuel_type)) || return

    end_date = meter.amr_data.end_date
    start_date = [end_date - 365, meter.amr_data.start_date].max
    begin
      collated_data = collate_data(school, meter, start_date, end_date)
    rescue StandardError => e
      @logger.error(e)
      return
    end
    (@school_type_samples[school.school_type.to_sym] ||= Hash.new(0))[fuel_type] += 1
    factor = normalising_factor(school, meter, start_date, end_date)
    average_data(collated_data, factor)
  end

  def get_meter(school, fuel_type)
    return unless SCHOOL_TYPES.include?(school.school_type.to_sym)

    meter = school.aggregate_meter(fuel_type)

    return if meter.nil? || meter.amr_data.days < 50

    return if fuel_type == :gas && meter.amr_data.days < 350 # degreeday adjustment wont work otherwise

    meter
  end

  def normalising_factor(school, meter, start_date, end_date)
    if meter.fuel_type == :electricity
      1.0 / school.number_of_pupils(start_date, end_date)
    else
      degree_days_to_average_factor(school, start_date, end_date) / school.floor_area(start_date, end_date)
    end
  end

  def degree_days_to_average_factor(school, start_date, end_date)
    avg_degree_days = BenchmarkMetrics::ANNUAL_AVERAGE_DEGREE_DAYS

    school_degree_days = school.temperatures.degree_days_in_date_range(start_date, end_date)

    # very crude for as really need to scale monthly degree days
    # versus precalculated national average for each month
    # school.aggregated_heat_meters.heating_model.heating_on?(date)

    # if a school is colder than average i.e. > school_degree_days reduce its consumption for average
    avg_degree_days / school_degree_days
  end

  def collate_data(school, meter, start_date, end_date)
    data = { schoolday: {}, holiday: {}, weekend: {} }

    (start_date..end_date).each do |date|
      day_type = school.holidays.day_type(date)
      month = month_or_holiday(school, date)
      data[day_type][month] ||= []
      data[day_type][month].push(meter.amr_data.days_kwh_x48(date))
    end

    data
  end

  def month_or_holiday(school, date)
    if school.holidays.day_type(date) == :holiday
      holiday_type = school.holidays.holiday(date).type
      AverageSchoolCalculator.remap_low_sample_holiday(holiday_type, date)
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

  def index_range_from_rank_range(length, rank_range)
    index_range_low  = (length * rank_range.first).to_i
    index_range_high = (length * rank_range.last).to_i
    index_range_low..index_range_high
  end
end
