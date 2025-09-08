#======================== Heating Sensitivity Advice ==============
require_relative '../alert_gas_model_base.rb'
require_relative '../../common/alert_floor_area_pupils_mixin.rb'

class AlertHeatingSensitivityAdvice < AlertGasModelBase
  include AlertFloorAreaMixin
  MIN_REPORTED_SENSITIVITY_£ = 50.0
  attr_reader :annual_saving_1_C_change_kwh, :annual_saving_1_C_change_£, :annual_saving_1_C_change_co2, :annual_saving_1_C_change_percent
  attr_reader :fabric_boiler_efficiency_kwh_c_per_1000_m2_floor_area_day

  def initialize(school)
    super(school, :heatingsensitivity)
    @relevance = :never_relevant if @relevance != :never_relevant && non_heating_only
  end

  def self.template_variables
    specific = {'Temperature change advice' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    enough_data_for_model_fit ? :enough : :not_enough
  end

  TEMPLATE_VARIABLES = {
    annual_saving_1_C_change_kwh: {
      description: 'Predicted annual reduction in heating consumption if thermostat turned down 1C (kWh)',
      units:  {kwh: :gas}
    },
    annual_saving_1_C_change_£: {
      description: 'Predicted annual reduction in heating consumption if thermostat turned down 1C (£)',
      units:  :£,
      benchmark_code: 'td1c'
    },
    annual_saving_1_C_change_co2: {
      description: 'Predicted annual reduction in heating consumption if thermostat turned down 1C (co2)',
      units:  :co2,
      benchmark_code: 'tc1c'
    },
    annual_saving_1_C_change_percent: {
      description: 'Predicted annual reduction in heating consumption if thermostat turned down 1C (% of annual gas consumption)',
      units:  :percent
    },
    fabric_boiler_efficiency_kwh_c_per_1000_m2_floor_area_day: {
      description: 'Measure of combined fabric and boiler efficiency (kWh/1C dT/1000m2/day)',
      units:  :kwh
    }
  }

  private def calculate(asof_date)
    calculate_model(asof_date)
    start_date = [asof_date - 365, @school.aggregated_heat_meters.amr_data.start_date].max
    @months = ((asof_date - start_date) / 30.0).floor
    @annual_saving_1_C_change_kwh = @heating_model.kwh_saving_for_1_C_thermostat_reduction(start_date, asof_date)
    @annual_kwh = kwh(start_date, asof_date)
    @annual_saving_1_C_change_percent = @annual_saving_1_C_change_kwh / @annual_kwh
    @annual_saving_1_C_change_kwh *= (365 / (asof_date - start_date)) # scale to 1 year
    @annual_saving_1_C_change_£   = @annual_saving_1_C_change_kwh * aggregate_meter.amr_data.current_tariff_rate_£_per_kwh
    @annual_saving_1_C_change_co2 = @annual_saving_1_C_change_kwh * EnergyEquivalences.co2_kg_kwh(:gas)
    assign_commmon_saving_variables(
      one_year_saving_kwh: @annual_saving_1_C_change_kwh,
      one_year_saving_£: @annual_saving_1_C_change_£,
      one_year_saving_co2: @annual_saving_1_C_change_co2)

    @fabric_boiler_efficiency_kwh_c_per_1000_m2_floor_area_day = 1000.0 * heating_model.average_heating_b_kwh_per_1_C_per_day / floor_area(asof_date - 365, asof_date)
    @rating = @annual_saving_1_C_change_£ > MIN_REPORTED_SENSITIVITY_£ ? 5.0 : 10.0
  end
  alias_method :analyse_private, :calculate
end
