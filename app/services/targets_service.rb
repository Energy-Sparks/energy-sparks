# frozen_string_literal: true

class TargetsService
  include Logging

  def initialize(aggregate_school, fuel_type, period: :year)
    @aggregate_school = aggregate_school
    @fuel_type = set_fuel_type(fuel_type)
    @period = period
  end

  # Called by application to determine if we have enough data for a school to
  # set and calculate a target. Should cover all necessary data
  #
  # We require at least a years worth of calendar data, as well as ~1 year of AMR data OR an estimate of their annual consumption
  def enough_data_to_set_target?
    !fuel_type_disabled? && enough_holidays? && enough_temperature_data? &&
      (enough_readings_to_calculate_target? || enough_estimate_data_to_calculate_target?)
  end

  def enough_holidays?
    TargetMeter.enough_holidays?(aggregate_meter)
  end

  def default_target_start_date
    TargetDates.default_target_start_date(aggregate_meter)
  end

  # Are there enough historical meter readings to calculate a target?
  # This should be checking whether there’s enough historical data, regardless of
  # whether the data is currently lagging behind (see below). So checking for the
  # oldest data, not the most recent.
  def enough_readings_to_calculate_target?
    return false if aggregate_meter.nil?

    one_year_of_meter_readings_available_prior_to_1st_date?
  end

  # Is there enough data to produce an estimate of historical usage to calculate a target.
  # Checks if the estimate attribute needs to be, and is, set
  # Might also need some minimal readings
  def enough_estimate_data_to_calculate_target?
    annual_kwh_estimate_required? && annual_kwh_estimate? && can_calculate_one_year_of_synthetic_data?
  end

  # Used by the front-end to check whether to suggest to users that they provide
  # an estimate.
  #
  # Checks whether one is needed, whether one has been set and whether
  # we can calculate the synthetic data is one is eventually provided
  #
  # This avoids suggesting an estimate if we using it won't help
  def suggest_use_of_estimate?
    # TEMPORARY: the call to annual_kwh_estimate_helpful? fails if there's no target set
    # the application calls this method for all schools regardless of whether a target has
    # been set to determine whether an estimate might be useful. This allows us to immediately
    # prompt for an estimate when they've set a target. Handling this here, pending any changes
    # to the date logic. In the case where there's no target, the TargetDates should be answering
    # as if the target started from today.
    if target_set?
      annual_kwh_estimate_helpful? && can_calculate_one_year_of_synthetic_data?
    else
      annual_kwh_estimate_required? && !annual_kwh_estimate? && can_calculate_one_year_of_synthetic_data?
    end
  end

  # one year of meter readings are required prior to the first target date
  # in order to calculate a target for the following year in the absence
  # of needing to calculate a full year of data synthetically using an 'annual kWh estimate'
  # however, a year after setting the target, the target_start date for calculation purposes
  # will incrementally move at 1 year behind the most recent meter reading date - at this point
  # there may be enough real historic meter readings for a meter which originally has less
  # then 1 year's data to have 1 year of data and not required the 'annual kWh estimate' and
  # therefore the synthetic calculation
  def one_year_of_meter_readings_available_prior_to_1st_date?
    TargetDates.one_year_of_meter_readings_available_prior_to_1st_date?(aggregate_meter)
  end

  def can_calculate_one_year_of_synthetic_data?
    TargetDates.can_calculate_one_year_of_synthetic_data?(aggregate_meter)
  end

  def annual_kwh_estimate?
    aggregate_meter.estimated_period_consumption_set?
  end

  def annual_kwh_estimate_required?
    TargetMeter.annual_kwh_estimate_required?(aggregate_meter)
  end

  # def annual_kwh_estimate_helpful?
  #   TargetMeter.annual_kwh_estimate_helpful?(aggregate_meter)
  # end

  # use model to calculate prorata type estimate of annual kwh in abscence of full year data
  def annual_kwh_estimate_kwh
    return nil if aggregate_meter.nil?

    estimator = AnnualKwhEstimate.new(aggregate_meter)
    estimator.calculate_apportioned_annual_estimate
  rescue BivariateSolarTemperatureModel::BivariateModel::BivariateModelCalculationFailed => e
    # statsample error: blows up without raising named exception, so reraise from ES wrapped library
    logger.info "Electrical model failure: #{e.message}"
    nil
  end

  # def invalid_annual_estimate_less_than_historic_kwh_data_to_date?
  #   [MissingGasEstimationBase::MoreDataAlreadyThanEstimate,
  #    MissingElectricityEstimation::MoreDataAlreadyThanEstimate]
  #     .include?(target_meter_calculation_problem&.[](:type))
  # end

  # returns nil if ok, otherwise { text: "error message", type: ExceptionClass from POTENTIAL_EXPECTED_TARGET_METER_CREATION_ERRORS }
  # def target_meter_calculation_problem
  #   target_meter # forces calculation
  #   target_school.reason_for_nil_meter(@fuel_type)
  # end

  # go off to internet to pick up DEC data
  # def dec_annual_kwh_estimate_kwh
  #   dec = DisplayEnergyCertificate.new.recent_aggregate_data(@aggregate_school.postcode)
  #   @fuel_type == :electricity ? dec[:electricity_kwh] : dec[:heating_kwh]
  # end

  def recent_data?
    TargetMeter.recent_data?(aggregate_meter)
  end

  def enough_temperature_data?
    @fuel_type == :electricity || @aggregate_school.temperatures.days > 365 * 2
  end

  # Not used by application currently
  # def valid?
  #   !aggregate_meter.nil? &&
  #     target_set? &&
  #     #    recent_data? &&
  #     enough_data_to_set_target? &&
  #     !target_meter.nil?
  # end

  def meter_present?
    aggregate_meter.present?
  end

  # Does the analytics think there's a target set?
  # delegate :target_set?, to: :aggregate_meter

  # returns hash, value-attribute list,
  # .to_s key & value to view,
  # needs to be called after target meter data calculated
  # def analytics_debug_info
  #   valid? ? target_meter.analytics_debug_info : {}
  # end

  # def culmulative_progress_chart
  #   case @fuel_type
  #   when :electricity
  #     :targeting_and_tracking_weekly_electricity_to_date_cumulative_line
  #   when :gas
  #     :targeting_and_tracking_weekly_gas_to_date_cumulative_line
  #   when :storage_heater
  #     :targeting_and_tracking_weekly_storage_heater_to_date_cumulative_line
  #   end
  # end

  # def weekly_progress_chart
  #   case @fuel_type
  #   when :electricity
  #     :targeting_and_tracking_weekly_electricity_to_date_line
  #   when :gas
  #     :targeting_and_tracking_weekly_gas_to_date_line
  #   when :storage_heater
  #     :targeting_and_tracking_weekly_storage_heater_to_date_line
  #   end
  # end

  # def weekly_progress_to_date_chart
  #   case @fuel_type
  #   when :electricity
  #     :targeting_and_tracking_weekly_electricity_one_year_line
  #   when :gas
  #     :targeting_and_tracking_weekly_gas_one_year_line
  #   when :storage_heater
  #     :targeting_and_tracking_weekly_storage_heater_one_year_line
  #   end
  # end

  # def self.analytics_relevant(meter)
  #   rel = !meter.nil? && meter.target_set?
  #   rel ? :relevant : :never_relevant
  # end

  private

  def fuel_type_disabled?
    ENV["FEATURE_FLAG_TARGETS_DISABLE_#{@fuel_type.to_s.upcase}"] == 'true'
  end

  # def target_school
  #   @target_school ||= @aggregate_school.target_school
  # end

  # def target_meter
  #   @target_meter ||= target_school.aggregate_meter(@fuel_type)
  # end

  def aggregate_meter
    @aggregate_meter ||= @aggregate_school.aggregate_meter(@fuel_type)
  end

  def set_fuel_type(fuel_type)
    fuel_type == :storage_heaters ? :storage_heater : fuel_type
  end
end
