# frozen_string_literal: true

module BenchmarkMetrics
  # rubocop:disable Style/ClassVars
  @@current_prices = nil
  # rubocop:enable Style/ClassVars

  ELECTRICITY_PRICE = 0.15
  SOLAR_EXPORT_PRICE = 0.05
  GAS_PRICE = 0.03

  #
  # updated with July 2026 figures - see the Analytics Benchmarking Values spreadsheet
  #
  # Annual alectricity Usage per pupil benchmark figures
  BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL = 229.0 # No heat pump
  BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_HEAT_PUMP = 335.0 # With a heat pump
  BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL = 966.0

  EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL = 195.0 # No heat pump
  EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_HEAT_PUMP = 273.0 # With a heat pump
  EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL = 857.0

  # Secondary electricity usage typically higher due extra hours and server ICT
  RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE = 1.6 # No heat pump
  RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE_HEAT_PUMP = 1.1 # With heat pump

  BENCHMARK_ELECTRICITY_USAGE_PER_M2 = 50_000.0 / 1_200.0
  BENCHMARK_GAS_USAGE_PER_PUPIL = 435.0
  BENCHMARK_GAS_USAGE_PER_M2 = 61.0
  EXEMPLAR_GAS_USAGE_PER_M2 = 52.0
  LONG_TERM_ELECTRICITY_CO2_KG_PER_KWH = 0.15
  ANNUAL_AVERAGE_DEGREE_DAYS = 2000.0
  AVERAGE_GAS_PROPORTION_OF_HEATING = 0.6

  AVERAGE_OUT_OF_HOURS_PERCENT = 0.5

  #
  # updated with July 2026 figures - see the Analytics Benchmarking Values spreadsheet
  #
  EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY = 0.54
  BENCHMARK_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY = 0.58

  EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_GAS = 0.56
  BENCHMARK_OUT_OF_HOURS_USE_PERCENT_GAS = 0.62

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
  # @param boolean heat_pump Whether the school has a heat pump (of any kind)
  def self.benchmark_annual_electricity_usage_kwh(school_type, pupils = 1, heat_pump = false) # rubocop:todo Style/OptionalBooleanParameter
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type, 'benchmark electricity usage per pupil')

    case school_type
    when :primary, :infant, :junior, :middle, :mixed_primary_and_secondary
      pupils * (heat_pump ? BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_HEAT_PUMP : BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL)
    when :special
      pupils * BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL
    when :secondary
      if heat_pump
        pupils * BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_HEAT_PUMP * RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE_HEAT_PUMP
      else
        pupils * BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL * RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE
      end
    end
  end

  # Calculate the expected annual electricity use per pupil for an exemplar
  # school of a specific type and size
  #
  # @param Symbol school_type The symbol representing the type of school
  # @param Integer pupils The number of pupils
  # @param boolean heat_pump Whether the school has a heat pump (of any kind)
  def self.exemplar_annual_electricity_usage_kwh(school_type, pupils = 1, heat_pump = false) # rubocop:todo Style/OptionalBooleanParameter
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type, 'benchmark electricity usage per pupil')

    case school_type
    when :primary, :infant, :junior, :middle, :mixed_primary_and_secondary
      pupils * (heat_pump ? EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_HEAT_PUMP : EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL)
    when :special
      pupils * EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL
    when :secondary
      if heat_pump
        pupils * EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_HEAT_PUMP * RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE_HEAT_PUMP
      else
        pupils * EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL * RATIO_PRIMARY_TO_SECONDARY_ELECTRICITY_USAGE
      end
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
      BenchmarkMetrics.exemplar_annual_electricity_usage_kwh(school.school_type,
                                                             number_of_pupils,
                                                             school.heat_pump?)
    when :gas
      floor_area = school.aggregated_heat_meters.meter_floor_area(school, start_date, end_date)
      BenchmarkMetrics::EXEMPLAR_GAS_USAGE_PER_M2 * floor_area
    end
  end

  def self.recommended_baseload_for_pupils(pupils, school_type, heat_pump = false) # rubocop:todo Metrics/MethodLength, Style/OptionalBooleanParameter
    school_type = school_type.to_sym if school_type.instance_of? String
    check_school_type(school_type)

    case school_type
    when :primary, :infant, :junior
      if heat_pump
        baseload_with_threshold(
          pupils: pupils,
          base: 2.0,
          threshold: 135.0,
          increment: 1.5,
          divisor: 100.0
        )
      else
        baseload_with_threshold(
          pupils: pupils,
          base: 1.0,
          threshold: 90.0,
          increment: 1.12,
          divisor: 100.0
        )
      end
    when :special
      baseload_with_threshold(
        pupils: pupils,
        base: 2.5,
        threshold: 40.0,
        increment: 2.25,
        divisor: 40.0
      )
    when :secondary, :middle, :mixed_primary_and_secondary
      if heat_pump
        baseload_with_threshold(
          pupils: pupils,
          base: 11.0,
          threshold: 500.0,
          increment: 10.21,
          divisor: 500.0
        )
      else
        baseload_with_threshold(
          pupils: pupils,
          base: 13.5,
          threshold: 500.0,
          increment: 13.27,
          divisor: 500.0
        )
      end
    end
  end

  private_class_method def self.baseload_with_threshold(pupils:, base:, threshold:, increment:, divisor:)
    return base if pupils < threshold

    base + increment * (pupils - threshold) / divisor
  end

  def self.exemplar_baseload_for_pupils(pupils, school_type, heat_pump = false) # rubocop:todo Style/OptionalBooleanParameter
    recommended_baseload = recommended_baseload_for_pupils(pupils, school_type, heat_pump)
    case school_type
    when :primary, :infant, :junior
      if heat_pump
        0.8 * recommended_baseload
      else
        0.775 * recommended_baseload
      end
    when :special
      0.8 * recommended_baseload
    when :secondary, :middle, :mixed_primary_and_secondary
      if heat_pump
        0.8 * recommended_baseload
      else
        0.83 * recommended_baseload
      end
    end
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

  # Based on W/pupil figures in Peak_Benchmarks_2026.xlsx
  def self.exemplar_peak_kw(pupils, school_type)
    case school_type&.to_sym
    when :primary, :infant, :junior
      0.078 * pupils
    when :secondary, :middle, :mixed_primary_and_secondary
      0.103 * pupils
    when :special
      0.211 * pupils
    else
      raise EnergySparksUnexpectedStateException, "Unknown type of school #{school_type} in baseload floor area request"
    end
  end

  # Based on W/pupil figures in Peak_Benchmarks_2025.xlsx
  def self.benchmark_peak_kw(pupils, school_type)
    case school_type&.to_sym
    when :primary, :infant, :junior
      0.090 * pupils
    when :secondary, :middle, :mixed_primary_and_secondary
      0.115 * pupils
    when :special
      0.278 * pupils
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
      benchmark_annual_electricity_usage_kwh(school.school_type, 1, school.heat_pump?)
    else # :exemplar
      exemplar_annual_electricity_usage_kwh(school.school_type, 1, school.heat_pump?)
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
