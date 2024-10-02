class MissingGasEstimation < MissingGasEstimationBase
  def calculate_missing_gas
    calc_class = case gas_methodology
    when :model
      MissingGasModelEstimation
    when :degree_days
      MissingGasDegreeDayEstimation
    end

    calculator = calc_class.new(@meter, @annual_kwh, @target_dates)
    calculator.complete_year_amr_data
  end

  private

  def gas_methodology
    heating_model
    :model
  rescue EnergySparksNotEnoughDataException => _e
    :degree_days
  end
end
