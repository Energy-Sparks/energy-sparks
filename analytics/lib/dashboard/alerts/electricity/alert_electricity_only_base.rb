require_relative '../common/alert_analysis_base'

class AlertElectricityOnlyBase < AlertAnalysisBase
  include ElectricityCostCo2Mixin

  def maximum_alert_date
    aggregate_meter.amr_data.end_date
  end

  def time_of_year_relevance
    set_time_of_year_relevance(5.0)
  end

  def aggregate_meter
    @school.aggregated_electricity_meters
  end

  protected

  def needs_gas_data?
    false
  end
end
