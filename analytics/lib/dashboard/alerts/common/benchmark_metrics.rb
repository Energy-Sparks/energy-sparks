# frozen_string_literal: true

module BenchmarkMetrics
  # rubocop:disable Style/ClassVars
  @@current_prices = nil
  # rubocop:enable Style/ClassVars

  ELECTRICITY_PRICE = 0.15
  SOLAR_EXPORT_PRICE = 0.05
  GAS_PRICE = 0.03

  #
  # updated with July 2025 figures - see the Analytics Benchmarking Values spreadsheet
  #
  # Annual alectricity Usage per pupil benchmark figures
  BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL = 221.0
  BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL = 942.0
  EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL = 196.0
  EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL = 727.0
  # Secondary electricity usage typically higher due extra hours and server ICT
  RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE = 1.7

  BENCHMARK_ELECTRICITY_USAGE_PER_M2 = 50_000.0 / 1_200.0
  BENCHMARK_GAS_USAGE_PER_PUPIL = 419.0
  BENCHMARK_GAS_USAGE_PER_M2 = 62.0
  EXEMPLAR_GAS_USAGE_PER_M2 = 51.0
  LONG_TERM_ELECTRICITY_CO2_KG_PER_KWH = 0.15
  ANNUAL_AVERAGE_DEGREE_DAYS = 2000.0
  AVERAGE_GAS_PROPORTION_OF_HEATING = 0.6

  AVERAGE_OUT_OF_HOURS_PERCENT = 0.5

  # Out of hours metrics recalculated in Feb 2023, see trello
  # https://trello.com/c/FdBEY5Qz/2903-revise-approach-for-calculating-out-of-hours-usage-benchmark
  EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY = 0.5
  BENCHMARK_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY = 0.55

  EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_GAS = 0.55
  BENCHMARK_OUT_OF_HOURS_USE_PERCENT_GAS = 0.6

  EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_STORAGE_HEATER = 0.2
  BENCHMARK_OUT_OF_HOURS_USE_PERCENT_STORAGE_HEATER = 0.5

  # rubocop:disable Style/ClassVars
  def self.set_current_prices(prices:)
    @@current_prices = prices
  end

  def self.pricing
    @@current_prices || default_prices
  end
  # rubocop:enable Style/ClassVars

  def self.default_prices
    OpenStruct.new(
      gas_price: BenchmarkMetrics::GAS_PRICE,
      electricity_price: BenchmarkMetrics::ELECTRICITY_PRICE,
      solar_export_price: BenchmarkMetrics::SOLAR_EXPORT_PRICE
    )
  end

  # BENCHMARK_ENERGY_COST_PER_PUPIL = BENCHMARK_GAS_USAGE_PER_PUPIL * GAS_PRICE +
  #                                  BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL * ELECTRICITY_PRICE

  # number less than 1.0 for colder area, > 1.0 for milder areas
  # multiply by this number if normalising school to other schools in different regions
  # divide by this number if scaling a central UK wide benchmark to a school
  def self.normalise_degree_days(regional_temperatures, _holidays, fuel_type, asof_date)
    regional_degree_days = regional_temperatures.degree_days_this_year(asof_date)
    if fuel_type == :gas
      scale_percent_towards_one(ANNUAL_AVERAGE_DEGREE_DAYS / regional_degree_days, AVERAGE_GAS_PROPORTION_OF_HEATING)
    elsif %i[electricity storage_heaters].include?(fuel_type)
      ANNUAL_AVERAGE_DEGREE_DAYS / regional_degree_days
    else
      raise EnergySparksUnexpectedStateException, "Not expecting fuel type #{fuel_type} for degree day adjustment"
    end
  end

  # Only called from AlertEnergyAnnualVersusBenchmark
  def self.benchmark_energy_usage_£_per_pupil(benchmark_type, school, asof_date, list_of_fuels)
    total = 0.0
    total += benchmark_electricity_usage_£_per_pupil(benchmark_type, school) if list_of_fuels.include?(:electricity)
    total += benchmark_heating_usage_£_per_pupil(benchmark_type, school, asof_date, :gas) if list_of_fuels.include?(:gas)
    total += benchmark_heating_usage_£_per_pupil(benchmark_type, school, asof_date, :storage_heaters) if list_of_fuels.include?(:storage_heater) || list_of_fuels.include?(:storage_heaters)
    total
  end

  # Calculate the expected annual electricity use per pupil for a benchmark
  # ("Well managed") school of a specific type and size
  #
  # @param Symbol school_type The symbol representing the type of school
  # @param Integer pupils The number of pupils
  def self.benchmark_annual_electricity_usage_kwh(school_type, pupils = 1)
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type, 'benchmark electricity usage per pupil')

    case school_type
    when :primary, :infant, :junior, :middle, :mixed_primary_and_secondary
      BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL * pupils
    when :special
      BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL * pupils
    when :secondary
      RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE * BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL * pupils
    end
  end

  # Calculate the expected annual electricity use per pupil for an exemplar
  # school of a specific type and size
  #
  # @param Symbol school_type The symbol representing the type of school
  # @param Integer pupils The number of pupils
  def self.exemplar_annual_electricity_usage_kwh(school_type, pupils = 1)
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type, 'benchmark electricity usage per pupil')

    case school_type
    when :primary, :infant, :junior, :middle, :mixed_primary_and_secondary
      EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL * pupils
    when :special
      EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL * pupils
    when :secondary
      RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE * EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL * pupils
    end
  end

  # used by ManagementSummaryTable
  def self.exemplar_£(school, fuel_type, start_date, end_date)
    case fuel_type
    when :electricity, :storage_heater, :storage_heaters
      exemplar_kwh(school, fuel_type, start_date, end_date) * electricity_price_£_per_kwh(school)
    when :gas
      exemplar_kwh(school, fuel_type, start_date, end_date) * gas_price_£_per_kwh(school)
    end
  end

  def self.exemplar_kwh(school, fuel_type, start_date, end_date)
    case fuel_type
    when :electricity, :storage_heater, :storage_heaters
      number_of_pupils = school.aggregated_electricity_meters.meter_number_of_pupils(school, start_date, end_date)
      BenchmarkMetrics.exemplar_annual_electricity_usage_kwh(school.school_type, number_of_pupils)
    when :gas
      floor_area = school.aggregated_heat_meters.meter_floor_area(school, start_date, end_date)
      BenchmarkMetrics::EXEMPLAR_GAS_USAGE_PER_M2 * floor_area
    end
  end

  def self.recommended_baseload_for_pupils(pupils, school_type)
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type)

    case school_type
    when :primary, :infant, :junior
      if pupils < 150
        1.0
      else
        1.0 + 1.0 * (pupils - 150) / 100
      end
    when :special
      if pupils < 30
        2.5
      else
        2.5 + 1.8 * (pupils - 30) / 30
      end
    when :secondary, :middle, :mixed_primary_and_secondary
      if pupils < 500
        10
      else
        10 + 9.5 * (pupils - 500) / 500
      end
    end
  end

  def self.exemplar_baseload_for_pupils(pupils, school_type)
    # arbitrarily 60% for the moment TODO(PH, 11Apr2019)
    0.6 * recommended_baseload_for_pupils(pupils, school_type)
  end

  def self.typical_servers_for_pupils(school_type, pupils)
    school_type = school_type.to_sym if school_type.instance_of? String
    servers = 1
    power = 500.0
    case school_type
    when :primary, :infant, :junior, :special
      servers = if pupils < 100
                  2
                elsif pupils < 300
                  3
                else
                  3 + (pupils / 300).floor
                end
    when :secondary, :middle, :mixed_primary_and_secondary
      power = 1000.0
      servers = if pupils < 400
                  4
                elsif pupils < 1000
                  8
                else
                  8 + ((pupils - 1000) / 250).floor
                end
    else
      raise EnergySparksUnexpectedStateException, "Unknown type of school #{school_type} in typical servers request" unless school_type.nil?
      raise EnergySparksUnexpectedStateException, 'Nil type of school in typical servers request' if school_type.nil?
    end
    [servers, power]
  end

  # Based on W/pupil figures in Peak_Benchmarks_2025.xlsx
  def self.exemplar_peak_kw(pupils, school_type)
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type)
    case school_type
    when :primary, :infant, :junior
      0.077 * pupils
    when :secondary, :middle, :mixed_primary_and_secondary
      0.105 * pupils
    when :special
      0.242 * pupils
    else
      raise EnergySparksUnexpectedStateException, "Unknown type of school #{school_type} in baseload floor area request"
    end
  end

  # Based on W/pupil figures in Peak_Benchmarks_2025.xlsx
  def self.benchmark_peak_kw(pupils, school_type)
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type)
    case school_type
    when :primary, :infant, :junior
      0.087 * pupils
    when :secondary, :middle, :mixed_primary_and_secondary
      0.116 * pupils
    when :special
      0.290 * pupils
    else
      raise EnergySparksUnexpectedStateException, "Unknown type of school #{school_type} in baseload floor area request"
    end
  end

  # p = 110%, s = 60% => 106%
  private_class_method def self.scale_percent_towards_one(percent, scale)
    ((percent - 1.0) * scale) + 1.0
  end

  private_class_method def self.check_school_type(school_type, type = 'baseload benckmark')
    raise EnergySparksUnexpectedStateException, "Nil type of school in #{type} request" if school_type.nil?
    return if %i[primary infant junior special middle secondary mixed_primary_and_secondary].include?(school_type)

    raise EnergySparksUnexpectedStateException, "Unknown type of school #{school_type} in #{type} request"
  end

  private_class_method def self.benchmark_electricity_usage_£_per_pupil(benchmark_type, school)
    benchmark_electricity_usage_kwh_per_pupil(benchmark_type, school) * electricity_price_£_per_kwh(school)
  end

  # @param Symbol benchmark_type Either :benchmark or :exemplar
  # @param MeterCollection school
  private_class_method def self.benchmark_electricity_usage_kwh_per_pupil(benchmark_type, school)
    if benchmark_type == :benchmark
      benchmark_annual_electricity_usage_kwh(school.school_type)
    else # :exemplar
      exemplar_annual_electricity_usage_kwh(school.school_type)
    end
  end

  # as above, larger number returned for Scotland, lower for SW
  private_class_method def self.benchmark_heating_usage_£_per_pupil(benchmark_type, school, asof_date = nil, fuel_type = :gas)
    if fuel_type == :gas
      benchmark_heating_usage_kwh_per_pupil(benchmark_type, school, asof_date, fuel_type) * gas_price_£_per_kwh(school)
    else # storage_heaters
      benchmark_heating_usage_kwh_per_pupil(benchmark_type, school, asof_date, fuel_type) * electricity_price_£_per_kwh(school)
    end
  end

  # scale benchmark to schools's temperature zone; so result if higher for
  # Scotland and lower for SW UK
  # also scales years, so all years normalised to same temperature
  private_class_method def self.benchmark_heating_usage_kwh_per_pupil(benchmark_type, school, asof_date = nil, fuel_type = :gas)
    dd_adj = normalise_degree_days(school.temperatures, school.holidays, fuel_type, asof_date)
    if benchmark_type == :benchmark
      BENCHMARK_GAS_USAGE_PER_PUPIL / dd_adj
    else # :exemplar
      EXEMPLAR_GAS_USAGE_PER_M2 / dd_adj
    end
  end

  private_class_method def self.electricity_price_£_per_kwh(school)
    school.aggregated_electricity_meters.amr_data.blended_rate(:kwh, :£)
  end

  private_class_method def self.gas_price_£_per_kwh(school)
    school.aggregated_heat_meters.amr_data.blended_rate(:kwh, :£)
  end
end
