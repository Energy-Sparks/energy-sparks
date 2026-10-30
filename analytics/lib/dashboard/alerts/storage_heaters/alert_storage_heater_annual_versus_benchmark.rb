require_relative '../gas/alert_gas_annual_versus_benchmark'
require_relative './alert_gas_to_storage_heater_substitution_mix_in'
require_relative '../electricity/electricity_cost_co2_mixin'

class AlertStorageHeaterAnnualVersusBenchmark < AlertGasAnnualVersusBenchmark
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def initialize(school)
    super(school, :storage_heater_annual_benchmark)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  private def dd_adj(asof_date)
    BenchmarkMetrics.normalise_degree_days(@school.temperatures, @school.holidays, :electricity, asof_date)
  end
end
