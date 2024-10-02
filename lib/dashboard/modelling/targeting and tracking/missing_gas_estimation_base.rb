require_relative './missing_energy_fitting_base.rb'
class MissingGasEstimationBase < MissingEnergyFittingBase
  class EnoughGas < StandardError; end
  class MoreDataAlreadyThanEstimate < StandardError; end
  class UnexpectedAbstractBaseClassRequest < StandardError; end
  include Logging

  def initialize(meter, annual_kwh, target_dates)
    super(meter.amr_data, meter.meter_collection.holidays)
    @meter = meter
    @annual_kwh = annual_kwh
    @target_dates = target_dates
    check_annual_estimate
    raise EnoughGas, "Unexpected request to fill in missing gas data as > 365 days (#{@amr_data.days})" if target_dates.days_benchmark_data > 365
  end

  def complete_year_amr_data
    raise UnexpectedAbstractBaseClassRequest, "Unexpected call to base class #{self.class.name}"
  end

  private

  def check_annual_estimate
    kwh_to_start_to_target = @meter.amr_data.kwh_date_range(@meter.amr_data.start_date, @target_dates.original_target_start_date)
    if kwh_to_start_to_target > @annual_kwh
      error = {
        text:                     "The estimate you've supplied (#{@annual_kwh.round(0)} kWh annualised) is less than your historic data (#{kwh_to_start_to_target.round(0)} kWh), so has not been applied. Please revise your estimate",
        total_kwh_to_start:       kwh_to_start_to_target,
        annualised_estimate_kwh:  @annual_kwh,
        type:                     MoreDataAlreadyThanEstimate
      }
      raise MoreDataAlreadyThanEstimate, error
    end
  end

  def one_year_amr_data
    @one_year_amr_data ||= AMRData.copy_amr_data(@amr_data, @target_dates.benchmark_start_date, @target_dates.original_meter_end_date)
  end

  def heating_model
    @heating_model ||= calculate_heating_model
  end

  def calculate_heating_model
    benchmark_period = SchoolDatePeriod.new(:available, 'target model', @target_dates.benchmark_start_date, @target_dates.benchmark_end_date)
    @meter.heating_model(benchmark_period)
  end

  def full_heating_model
    @full_heating_model ||= calculate_full_heating_model
  end

  def calculate_full_heating_model
    original_meter_period = SchoolDatePeriod.new(:available, 'target model', @target_dates.original_meter_start_date, @target_dates.original_meter_end_date)
    @meter.heating_model(original_meter_period)
  end
end
