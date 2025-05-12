require_relative './advice_gas_base.rb'

class AdviceBoilerHeatingBase < AdviceGasBase
  include Logging

  def relevance
    super == :relevant && !non_heating_only? ? :relevant : :never_relevant
  end

  def enough_data
    valid_model? && heating_model.includes_school_day_heating_models? ? :enough : :not_enough
  end

  def default_model
    :best
  end

  private

  def meter
    @school.aggregated_heat_meters
  end

  def heating_model(model_type: default_model)
    @heating_model ||= calculate_heating_model(model_type: model_type)
  end

  def valid_model?
    heating_model
    true
  rescue EnergySparksNotEnoughDataException => e
    logger.info "Not running #{self.class.name} because model hasnt fitted"
    logger.info e.message
    false
  end

  def calculate_heating_model(model_type: default_model)
    start_date = [meter.amr_data.end_date - 364, meter.amr_data.start_date].max
    last_year = SchoolDatePeriod.new(:analysis, 'validate amr', start_date, meter.amr_data.end_date)
    meter.heating_model(last_year, model_type)
  end

  def one_year_before_last_meter_date
    [last_meter_date - 364, aggregate_meter.amr_data.start_date].max
  end

  def last_meter_date
    aggregate_meter.amr_data.end_date
  end
end

class AdviceGasBoilerFrost < AdviceBoilerHeatingBase
  def rating
    5.0
  end
end
