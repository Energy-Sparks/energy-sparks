require_relative '../common/alert_analysis_base.rb'

class AlertGasOnlyBase < AlertAnalysisBase
  def initialize(school, _report_type)
    super(school, _report_type)
  end

  def maximum_alert_date
    aggregate_meter.amr_data.end_date
  end

  def needs_electricity_data?
    false
  end

  def self.template_variables
    specific = {'Gas Meters' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    non_heating_only: {
      description: 'Gas at this school is only used for hot water or in the kitchens',
      units:  TrueClass
    },
    kitchen_only: {
      description: 'Gas at this school is only used in the kitchens',
      units:  TrueClass
    },
    hot_water_only: {
      description: 'Gas at this school is only used just for hot water',
      units:  TrueClass
    },
    heating_only: {
      description: 'Gas at this school is only used heating and not for hot water or in the kitchens',
      units:  TrueClass
    }
  }.freeze

  def blended_gas_£_per_kwh
    @blended_gas_£_per_kwh ||= blended_rate(:£)
  end

  def last_meter_data_date
    aggregate_meter.amr_data.end_date
  end

  def time_of_year_relevance
    set_time_of_year_relevance(5.0)
  end

  def last_n_school_days_kwh(asof_date, school_days)
    kwhs = []
    days = last_n_school_days(asof_date, school_days)
    days.each do |date|
      kwhs.push(aggregate_meter.amr_data.one_day_kwh(date))
    end
    kwhs
  end

  protected def gas_cost_deprecated(kwh)
    kwh * fuel_price
  end

  protected def gas_co2(kwh)
    kwh * EnergyEquivalences.co2_kg_kwh(:gas)
  end

  def pipework_insulation_cost
    meters_pipework = floor_area / 5.0
    Range.new(meters_pipework * 5, meters_pipework * 15) # TODO(PH,11Mar2019) - find real figure to replace these?
  end

  def electric_point_of_use_hotwater_costs
    number_of_toilets = (pupils / 30.0)
    Range.new(number_of_toilets * 300.0, number_of_toilets * 600.0)
  end

  def aggregate_meter
    @school.aggregated_heat_meters
  end

  def fuel_price_deprecated
    blended_gas_£_per_kwh
  end

  def non_heating_only
    aggregate_meter.non_heating_only?
  end

  def kitchen_only
    aggregate_meter.kitchen_only?
  end

  def hot_water_only
    aggregate_meter.hot_water_only?
  end

  def heating_only
    aggregate_meter.heating_only?
  end
end
