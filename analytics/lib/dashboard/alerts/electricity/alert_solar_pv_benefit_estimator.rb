require_relative '../../../../app/services/solar_photovoltaics/potential_benefits_estimator_service'

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
      units:  :kwp
    },
    optimum_payback_years: {
      description: 'Payback period of optimum number of panels',
      units:  :years
    },
    optimum_mains_reduction_percent: {
      description: 'Optimum: percent redcution in mains consumption',
      units:  :percent
    },
    one_year_saving_£current: {
      description: 'Saving at latest tariffs for optimum scenario',
      units:  :£current
    }
  }

  def calculate(asof_date)
    service = ::SolarPhotovoltaics::PotentialBenefitsEstimatorService.new(meter_collection: @school, asof_date:)
    raise EnergySparksNotEnoughDataException, "Only #{days_data.to_i} days meter data" unless service.enough_data?

    optimum_scenario = service.calculate_optimum_scenario

    @optimum_kwp = optimum_scenario[:kwp]
    @optimum_payback_years = optimum_scenario[:payback_years]
    @optimum_mains_reduction_percent = optimum_scenario[:reduction_in_mains_percent]
    @one_year_saving_£current = optimum_scenario[:total_annual_saving_£]

    assign_commmon_saving_variables(
      one_year_saving_kwh: optimum_scenario[:reduction_in_mains_kwh],
      one_year_saving_£: @one_year_saving_£current,
      capital_cost: optimum_scenario[:capital_cost_£],
      one_year_saving_co2: optimum_scenario[:total_annual_saving_co2])

    @rating = 5.0
  end
  alias_method :analyse_private, :calculate
end
