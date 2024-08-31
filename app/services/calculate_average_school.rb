# frozen_string_literal: true

# require File.join(Bundler.rubygems.find_name('energy-sparks_analytics').first.full_gem_path,
#                   'test_support/school_factory')

class CalculateAverageSchool
  SCHOOL_TYPES = %i[primary secondary special].freeze # missing mixed?
  RANGES = {
    average: 0.4..0.6,
    benchmark: 0.2..0.4,
    exemplar: 0.1..0.25
  }.freeze

  def self.perform(s3: nil) # rubocop:disable Naming/MethodParameterName
    calc = new(s3 || Aws::S3::Client.new)
    data = {}
    fuel_types = %i[electricity gas]

    by_school_type = fuel_types.index_with { {} }
    calc.school_generator do |school|
      fuel_types.each do |fuel_type|
        school_data = calc.calculate_average_school(school, fuel_type)
        (by_school_type[fuel_type][school_data[:school_type]] ||= []).push(school_data) if school_data
        # debugger
      end
    end
    fuel_types.each do |fuel_type|
      RANGES.each_key do |type|
        (data[fuel_type] ||= {})[type] = calc.average_by_type_within_rank_range(by_school_type[fuel_type], RANGES[type])
        data[fuel_type][type].each_key do |school_type|
          data[fuel_type][type][school_type][:samples] = calc.school_type_samples[school_type][fuel_type]
        end
      end
    end

    data
    # calc.save_average_school_data_to_ruby_file(data, benchmark_type_config)
    # calc.save_average_school_data_to_csv(data)
  end

  attr_reader :school_type_samples

  def initialize(s3_client)
    @s3 = s3_client
    @school_type_samples = {}
  end

  def school_generator
    bucket = ENV.fetch('UNVALIDATED_SCHOOL_CACHE_BUCKET', nil)
    resp = @s3.list_objects_v2(bucket:, prefix: 'unvalidated-data-')
    # debugger
    resp.contents[..5].each do |content|
      # yield content.key
      yaml = YAML.unsafe_load(EnergySparks::Gzip.gunzip(@s3.get_object(bucket:, key: content.key).body.read))
      Rails.logger.info("loaded #{content.key}")
      Rails.logger.debug { "loaded #{content.key}" }
      meter_collection = build_meter_collection(yaml)
      AggregateDataService.new(meter_collection).validate_meter_data
      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
      yield meter_collection
    end
  end

  def calculate_average_school(school, fuel_type)
    school_type = school.school_type.to_sym
    return unless SCHOOL_TYPES.include?(school_type)

    meter = school.aggregate_meter(fuel_type)

    return if meter.nil? || meter.amr_data.days < 50

    return if fuel_type == :gas && meter.amr_data.days < 350 # degreeday adjustment wont work otherwise

    (@school_type_samples[school_type] ||= Hash.new(0))[fuel_type] += 1

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

  def group_by_school_types(school_averages)
    by_type = {}

    school_averages.each do |school_data|
      by_type[school_data[:school_type]] ||= []
      by_type[school_data[:school_type]].push(school_data)
    end

    by_type
  end

  def average_by_type_within_rank_range(by_school_type, rank_range)
    data_by_type_then_month_then_half_hour = group_by_type_then_month_then_half_hour(by_school_type)

    data = {}

    data_by_type_then_month_then_half_hour.each do |school_type, data_type_data|
      data[school_type] = {}
      data_type_data.each do |daytype, months_data|
        data[school_type][daytype] = {}
        months_data.each do |month, half_hour_data|
          data[school_type][daytype][month] = []
          half_hour_data.each do |half_hour, hh_kwh_x_n|
            sample_range = index_range_from_rank_range(hh_kwh_x_n.length, rank_range)

            to_average = hh_kwh_x_n.sort[sample_range]

            next if to_average.blank?

            avg = to_average.sum / to_average.length

            data[school_type][daytype][month][half_hour] = avg.round(6)
          end
        end
      end
    end

    data
  end

  def index_range_from_rank_range(length, rank_range)
    index_range_low  = (length * rank_range.first).to_i
    index_range_high = (length * rank_range.last).to_i
    index_range_low..index_range_high
  end

  def group_by_type_then_month_then_half_hour(by_school_type)
    data = group_by_type_then_month(by_school_type)

    data_by_month_half_hour = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }

    data.each do |school_type, data_type_data|
      data_type_data.each do |daytype, schools_data|
        schools_data.each do |school_data|
          months_or_holidays = daytype == :holiday ? Holidays::MAIN_HOLIDAY_TYPES : 1..12
          months_or_holidays.each do |month|
            (0..47).each do |half_hour|
              amr_x48 = school_data.dig(:amr_xN_x48, month)
              next if amr_x48.nil?

              unless data_by_month_half_hour[school_type][daytype][month][half_hour].is_a?(Array)
                data_by_month_half_hour[school_type][daytype][month][half_hour] =
                  []
              end
              data_by_month_half_hour[school_type][daytype][month][half_hour].push(amr_x48[half_hour])
            end
          end
        end
      end
    end

    data_by_month_half_hour
  end

  def group_by_type_then_month(by_school_type)
    data = {}

    by_school_type.each do |school_type, schools|
      data[school_type] ||= {}
      schools.each do |school|
        school[:monthly_data].each do |month, amr_x48|
          data[school_type][month] ||= []
          data[school_type][month].push({ school_name: school[:school_name], amr_xN_x48: amr_x48 })
        end
      end
    end

    data
  end

  def build_meter_collection(data, meter_attributes_overrides: {})
    # pseudo_meter_overrides, _meter_overrides = split_pseudo_and_non_pseudo_override_attributes(meter_attributes_overrides)
    meter_attributes = data[:pseudo_meter_attributes]

    MeterCollectionFactory.new(
      temperatures: data[:schedule_data][:temperatures],
      solar_pv: data[:schedule_data][:solar_pv],
      solar_irradiation: data[:schedule_data][:solar_irradiation],
      grid_carbon_intensity: data[:schedule_data][:grid_carbon_intensity],
      holidays: data[:schedule_data][:holidays]
    ).build(
      school_data: data[:school_data],
      amr_data: data[:amr_data],
      meter_attributes_overrides:,
      pseudo_meter_attributes: meter_attributes
    )
  end
end
