class AlertSolarGeneration < AlertElectricityOnlyBase

  attr_reader :annual_electricity_kwh, :annual_mains_consumed_kwh, :annual_solar_pv_kwh, :annual_exported_solar_pv_kwh, :annual_solar_pv_consumed_onsite_kwh

  def initialize(school)
    super(school, :solargeneration)
    @relevance = @school.solar_pv_panels? ? :relevant : :never_relevant
  end

  def self.template_variables
    specific = {'Solar Generation' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def enough_data
    return :not_enough unless @relevance == :relevant
    solar_benefits_service.enough_data? ? :enough : :not_enough
  end

  def timescale
    'year'
  end

  TEMPLATE_VARIABLES = {
    annual_electricity_kwh: {
      description: 'Total annual kwh, including self consumption',
      units:  :kwh,
      benchmark_code: 'sack'
    },
    annual_mains_consumed_kwh: {
      description: 'Total annual mains consumption kwh',
      units:  :kwh,
      benchmark_code: 'samk'
    },
    annual_solar_pv_kwh: {
      description: 'Total annual pv generation in kwh',
      units:  :kwh,
      benchmark_code: 'sagk'
    },
    annual_exported_solar_pv_kwh: {
      description: 'Total annual solar export in kwh',
      units:  :kwh,
      benchmark_code: 'saek'
    },
    annual_solar_pv_consumed_onsite_kwh: {
      description: 'Total annual solar self consumption in kwh',
      units:  :kwh,
      benchmark_code: 'sask'
    }
  }

  def calculate(asof_date)
    solar_generation_summary = solar_benefits_service.create_model

    #total including self consumption
    @annual_electricity_kwh = solar_generation_summary.annual_electricity_including_onsite_solar_pv_consumption_kwh
    #mains consumption
    @annual_mains_consumed_kwh =  solar_generation_summary.annual_consumed_from_national_grid_kwh
    #solar generation
    @annual_solar_pv_kwh = solar_generation_summary.annual_solar_pv_kwh
    #exported solar
    @annual_exported_solar_pv_kwh = solar_generation_summary.annual_exported_solar_pv_kwh
    #self consumption
    @annual_solar_pv_consumed_onsite_kwh = solar_generation_summary.annual_solar_pv_consumed_onsite_kwh

    @rating = 5.0
  end
  alias_method :analyse_private, :calculate

  private

  def solar_benefits_service
    SolarPhotovoltaics::ExistingBenefitsService.new(meter_collection: @school)
  end
end
