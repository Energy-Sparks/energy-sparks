#======================== Heating Sensitivity Advice ==============
require_relative '../alert_gas_model_base.rb'

class AlertHotWaterInsulationAdvice < AlertGasModelBase
  attr_reader :annual_hotwater_poor_insulation_heatloss_estimate_kwh
  attr_reader :annual_hotwater_poor_insulation_heatloss_estimate_percent
  attr_reader :annual_hotwater_poor_insulation_heatloss_estimate_£
  attr_reader :annual_hotwater_poor_insulation_heatloss_estimate_co2
  attr_reader :hotwater_poor_insulation_heatloss_chart

  def initialize(school)
    super(school, :hotwaterinsulation)
    if @relevance != :never_relevant && (heating_only || school.school.has_swimming_pool)
      @relevance = :never_relevant
    end
  end

  TEMPLATE_VARIABLES = {
    annual_hotwater_poor_insulation_heatloss_estimate_kwh: {
      description: 'Potential annual loss from poorly insulated hot water system - kwh',
      units: {kwh: :gas}
    },
    annual_hotwater_poor_insulation_heatloss_estimate_£: {
      description: 'Potential annual loss from poorly insulated hot water system - £',
      units:  :£,
    },
    annual_hotwater_poor_insulation_heatloss_estimate_co2: {
      description: 'Potential annual loss from poorly insulated hot water system - co2',
      units:  :co2,
    },
    annual_hotwater_poor_insulation_heatloss_estimate_percent: {
      description: 'Potential annual loss from poorly insulated hot water system - percent',
      units:  :percent
    },
    hotwater_poor_insulation_heatloss_chart: {
      description: 'Slope of summer hot water consumption regression line indicates poor insulation',
      units: :chart
    },
    pipework_insulation_cost: {
      description: 'Estimate of cost of insulating pipework',
      units: :£_range
    },
    electric_point_of_use_hotwater_costs: {
      description: 'Estimate of cost of replacing gas hot water system for electric point of use hot water heaters',
      units: :£_range
    }
  }.freeze

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    enough_data_for_model_fit ? :enough : :not_enough
  end

  def self.template_variables
    specific = {'Poorly Insulated Hot Water' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def hotwater_poor_insulation_heatloss_chart
    :thermostatic
  end

  def capital_cost
    Range.new(
      [pipework_insulation_cost.first, electric_point_of_use_hotwater_costs.first].min,
      [pipework_insulation_cost.last,  electric_point_of_use_hotwater_costs.last ].max
    )
  end

  def relevance
    @relevant = (aggregate_meter.nil? || heating_only) ? :never_relevant : :relevant
  end

  private def calculate_annual_hotwater_poor_insulation_heatloss_estimate(asof_date)
    start_date = model_start_date(asof_date)
    savings_kwh, savings_percent =
      heating_model.hot_water_poor_insulation_cost_kwh(start_date, asof_date)

    tariff_£_per_kwh = aggregate_meter.amr_data.current_tariff_rate_£_per_kwh

    @annual_hotwater_poor_insulation_heatloss_estimate_£    = savings_kwh * tariff_£_per_kwh
    @annual_hotwater_poor_insulation_heatloss_estimate_co2  = savings_kwh * EnergyEquivalences.co2_kg_kwh(:gas)
    @annual_hotwater_poor_insulation_heatloss_estimate_kwh  = savings_kwh
    @annual_hotwater_poor_insulation_heatloss_estimate_percent = savings_percent

    one_year_saving_£ = Range.new(@annual_hotwater_poor_insulation_heatloss_estimate_£ * 0.7, @annual_hotwater_poor_insulation_heatloss_estimate_£ * 1.3)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @annual_hotwater_poor_insulation_heatloss_estimate_kwh,
      one_year_saving_£: one_year_saving_£,
      one_year_saving_co2: @annual_hotwater_poor_insulation_heatloss_estimate_co2)
  end

  private def calculate(asof_date)
    calculate_model(asof_date)
    calculate_annual_hotwater_poor_insulation_heatloss_estimate(asof_date) if @annual_hotwater_poor_insulation_heatloss_estimate_kwh.nil?
    if annual_hotwater_poor_insulation_heatloss_estimate_percent == Float::INFINITY
      @rating = nil
      @status = :fail
    else
      @rating = ((1.0 - annual_hotwater_poor_insulation_heatloss_estimate_percent) * 10.0).round(0)
      @status = !enough_data ? :fail : (rating > 3.0 ? :good : :bad)
    end
    @term = :longterm
  end
  alias_method :analyse_private, :calculate
end
