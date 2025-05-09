module ElectricityCostCo2Mixin
  def blended_electricity_£_per_kwh
    @blended_electricity_£_per_kwh ||= blended_rate(:£)
  end

  def blended_co2_per_kwh
    @blended_co2_per_kwh ||= blended_rate(:co2)
  end
end
