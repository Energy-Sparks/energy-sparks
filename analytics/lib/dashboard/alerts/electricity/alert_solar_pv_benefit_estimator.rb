require 'minimization'
class AlertSolarPVBenefitEstimator < AlertElectricityOnlyBase
  attr_reader :optimum_kwp, :optimum_payback_years, :optimum_mains_reduction_percent
  attr_reader :one_year_saving_£current

  def initialize(school)
    super(school, :solarpvbenefitestimate)
    @relevance = (@relevance == :relevant && !@school.solar_pv_panels?) ? :relevant : :never_relevant
  end

  def self.template_variables
    specific = {'Solar PV Benefit Estimator' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def timescale
    'year'
  end

  def enough_data
    aggregate_meter.amr_data.days_valid_data > 364 ? :enough : :not_enough
  end

  TEMPLATE_VARIABLES = {
    optimum_kwp: {
      description: 'Optimum PV capacity for school (kWp)',
      units:  :kwp,
      benchmark_code: 'opvk'
    },
    optimum_payback_years: {
      description: 'Payback period of optimum number of panels',
      units:  :years,
      benchmark_code: 'opvy'
    },
    optimum_mains_reduction_percent: {
      description: 'Optimum: percent redcution in mains consumption',
      units:  :percent,
      benchmark_code: 'opvp'
    },
    one_year_saving_£current: {
      description: 'Saving at latest tariffs for optimum scenario',
      units:  :£current,
      benchmark_code: 'opv€'
    }
  }

  def calculate(asof_date)
    days_data = [aggregate_meter.amr_data.end_date, asof_date].min - aggregate_meter.amr_data.start_date
    raise EnergySparksNotEnoughDataException, "Only #{days_data.to_i} days meter data" unless days_data > 364

    #find optimum scenario
    optimum_kwp, @optimum_payback_years = optimum_payback(asof_date)

    @optimum_kwp = round_optimum_kwp(optimum_kwp)

    kwh_data = calculate_solar_pv_benefit(asof_date, @optimum_kwp)
    £_data = calculate_economic_benefit(kwh_data)
    optimum_scenario = kwh_data.merge(£_data)

    @optimum_mains_reduction_percent  = optimum_scenario[:reduction_in_mains_percent]

    @one_year_saving_£current = optimum_scenario[:total_annual_saving_£]

    assign_commmon_saving_variables(
      one_year_saving_kwh: optimum_scenario[:reduction_in_mains_kwh],
      one_year_saving_£: @one_year_saving_£current,
      capital_cost: optimum_scenario[:capital_cost_£],
      one_year_saving_co2: optimum_scenario[:total_annual_saving_co2])

    @rating = 5.0
  end
  alias_method :analyse_private, :calculate

  private

  def round_optimum_kwp(kwp)
    (kwp * 2.0).round(0) / 2.0
  end

  def max_possible_kwp
    # 25% of floor area, 6m2 panels/kWp
    (@school.floor_area * 0.25) / 6.0
  end

  def optimum_payback(asof_date)
    optimum = Minimiser.minimize(1, max_possible_kwp) {|kwp| payback(kwp, asof_date) }
    [optimum.x_minimum, optimum.f_minimum]
  end

  def payback(kwp, asof_date)
    kwh_data = calculate_solar_pv_benefit(asof_date, kwp)
    calculate_economic_benefit(kwh_data)[:payback_years]
  end

  def calculate_solar_pv_benefit(asof_date, kwp)
    start_date = asof_date - 365

    pv_panels = ConsumptionEstimator.new
    kwh_totals = pv_panels.annual_predicted_pv_totals_fast(aggregate_meter.amr_data, @school, start_date, asof_date, kwp)

    kwh = aggregate_meter.amr_data.kwh_date_range(start_date, asof_date)

    £   = aggregate_meter.amr_data.kwh_date_range(start_date, asof_date, :£current)

    {
      kwp:                          kwp,
      existing_annual_£:            £,
      new_mains_consumption_£:      kwh_totals[:new_mains_consumption_£],
      reduction_in_mains_kwh:       (kwh - kwh_totals[:new_mains_consumption]),
      reduction_in_mains_percent:   (kwh - kwh_totals[:new_mains_consumption]) / kwh,
      exported_kwh:                 kwh_totals[:exported],
      solar_pv_output_co2:          kwh_totals[:solar_pv_output] * blended_co2_per_kwh
    }
  end

  def number_of_panels(kwp)
    # assume 300 Wp per panel
    (kwp / 0.300).round(0).to_i
  end

  def panel_area_m2(panels)
    (panels * 1.6 * 0.9).round(0)
  end

  def calculate_economic_benefit(kwh_data)
    new_mains_cost = kwh_data[:new_mains_consumption_£]
    old_mains_cost = kwh_data[:existing_annual_£]
    export_income  = kwh_data[:exported_kwh] * BenchmarkMetrics.pricing.solar_export_price

    mains_savings   = old_mains_cost - new_mains_cost
    saving          = mains_savings  + export_income

    capital_cost    = capital_costs(kwh_data[:kwp])
    payback         = capital_cost / saving

    {
      total_annual_saving_£:    saving,
      total_annual_saving_co2:  kwh_data[:solar_pv_output_co2],
      capital_cost_£:           capital_cost,
      payback_years:            payback
    }
  end

  def capital_costs(kwp)
    # Costs estimated using range of data provided by Egni, BWCE, Ebay
    # See internal analysis spreadsheet. Updated 2023-06-09
    kwp == 0.0 ? 0.0 : (1584 * kwp**0.854)
  end

end
