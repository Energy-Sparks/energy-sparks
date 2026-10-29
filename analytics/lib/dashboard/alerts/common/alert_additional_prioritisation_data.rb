# frozen_string_literal: true

require_relative './alert_analysis_base.rb'

# not a real 'user' alert, but something which provides basic data to support the
# prioritisation of other alerts
class AlertAdditionalPrioritisationData < AlertAnalysisBase
  include Logging
  attr_reader :electricity_economic_tariff_changed_this_year, :electricity_economic_tariff_changed_in_the_previous_year, :electricity_economic_tariff_changed_this_year_percent,
              :electricity_economic_tariff_last_changed_date, :gas_economic_tariff_changed_this_year, :gas_economic_tariff_changed_in_the_previous_year, :gas_economic_tariff_changed_this_year_percent, :gas_economic_tariff_last_changed_date, :activation_date

  def initialize(school)
    super(school, :prioritisationdata)
    @relevance = :relevant # override gas only AlertGasModelBase values, so works for electricity as well
  end

  def relevance
    :relevant
  end

  def enough_data
    :enough
  end

  def self.template_variables
    { 'Prioritisation data' => TEMPLATE_VARIABLES }
  end

  TEMPLATE_VARIABLES = {
    pupils: {
      description: 'Number of pupils for relevant part of school on this date',
      units: Integer,
      benchmark_code: 'pupn'
    },
    floor_area: {
      description: 'Floor area of relevant part of school',
      units: :m2,
      benchmark_code: 'flra'
    },
    school_type_name: {
      description: 'Primary or Secondary',
      units: String,
      benchmark_code: 'stpn'
    },
    electricity_economic_tariff_changed_this_year: {
      description: 'Has the electricity economic changed in the last year',
      units: TrueClass,
      benchmark_code: 'etch'
    },
    electricity_economic_tariff_changed_in_the_previous_year: {
      description: 'Has the electricity economic changed in the previous year',
      units: TrueClass,
      benchmark_code: 'etcp'
    },
    electricity_economic_tariff_changed_this_year_percent: {
      description: 'Percent most recent electricity economic tariff change compared with average in remainder of this year',
      units: :percent,
      benchmark_code: 'etpc'
    },
    electricity_economic_tariff_last_changed_date: {
      description: 'The last date the electricity economic tariff changed for time varying economic tariffs',
      units: Date,
      benchmark_code: 'etcd'
    },
    gas_economic_tariff_changed_this_year: {
      description: 'Has the gas economic changed in the last year',
      units: TrueClass,
      benchmark_code: 'gtch'
    },
    gas_economic_tariff_changed_in_the_previous_year: {
      description: 'Has the gas economic changed in the previous year',
      units: TrueClass,
      benchmark_code: 'gtcp'
    },
    gas_economic_tariff_changed_this_year_percent: {
      description: 'Percent most recent gas economic tariff change compared with average in remainder of this year',
      units: :percent,
      benchmark_code: 'gtpc'
    },
    gas_economic_tariff_last_changed_date: {
      description: 'The last date the gas economic tariff changed for time varying economic tariffs',
      units: Date,
      benchmark_code: 'gtcd'
    },
    activation_date: {
      description: 'school activation date',
      units: Date,
      benchmark_code: 'sact'
    }
  }.freeze

  # dummy to keep ContentBase constructor happy
  def aggregate_meter
    meters = [@school.aggregated_electricity_meters, @school.aggregated_heat_meters]
    meters.compact[0]
  end

  def maximum_alert_date
    aggregate_meter.amr_data.end_date
  end

  def calculate(asof_date)
    calculate_private(asof_date)
  rescue StandardError => e
    logger.info e.message
    0.0
  end

  private

  def calculate_private(asof_date)
    @activation_date = @school.energysparks_start_date
    calculate_economic_tariff_data
  end

  def school_type_name
    I18n.t('analytics.school_types')[@school.school_type]
  end

  def calculate_economic_tariff_data
    unless @school.aggregate_meter(:electricity).nil?
      calc = AlertEconomicTariffCalculations.new(@school, @school.aggregate_meter(:electricity))

      @electricity_economic_tariff_changed_this_year            = calc.changed_this_year?
      @electricity_economic_tariff_changed_in_the_previous_year = calc.changed_previous_year?
      @electricity_economic_tariff_changed_this_year_percent    = calc.last_tariff_change_compared_with_remainder_of_last_year_percent
      @electricity_economic_tariff_last_changed_date            = calc.last_tariff_change_date
    end

    unless @school.aggregate_meter(:gas).nil?
      calc = AlertEconomicTariffCalculations.new(@school, @school.aggregate_meter(:gas))

      @gas_economic_tariff_changed_this_year            = calc.changed_this_year?
      @gas_economic_tariff_changed_in_the_previous_year = calc.changed_previous_year?
      @gas_economic_tariff_changed_this_year_percent    = calc.last_tariff_change_compared_with_remainder_of_last_year_percent
      @gas_economic_tariff_last_changed_date            = calc.last_tariff_change_date
    end
  rescue StandardError => e
    puts e.message
    puts e.backtrace
  end
end
