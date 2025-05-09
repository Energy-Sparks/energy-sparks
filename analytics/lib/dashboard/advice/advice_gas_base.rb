class AdviceGasBase < AdviceBase
  protected def aggregate_meter
    @school.aggregated_heat_meters
  end
  def relevance
    aggregate_meter.nil? ? :never_relevant : :relevant
  end
  def non_heating_only?
    aggregate_meter.non_heating_only?
  end
  def heating_only?
    aggregate_meter.heating_only?
  end
end
