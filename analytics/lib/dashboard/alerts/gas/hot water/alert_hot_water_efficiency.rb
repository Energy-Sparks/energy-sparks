#======================== Hot Water Efficiency =================================
require_relative '../alert_gas_model_base.rb'

class AlertHotWaterEfficiency < AlertGasModelBase
  attr_reader :investment_choices_table, :daytype_breakdown_table
  attr_reader :theoretical_annual_hot_water_requirement_litres, :theoretical_annual_hot_water_requirement_kwh
  attr_reader :avg_gas_per_pupil_£, :benchmark_existing_gas_efficiency
  attr_reader :benchmark_gas_better_control_saving_£, :benchmark_point_of_use_electric_saving_£, :electric_hot_water_saving_co2

  def initialize(school)
    super(school, :hotwaterefficiency)
    @relevance = :never_relevant if @relevance != :never_relevant && heating_only # set before calculation
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    begin
      hw_model = AnalyseHeatingAndHotWater::HotwaterModel.new(@school)
      summer_holidays = hw_model.find_period_before_and_during_summer_holidays(@school.holidays, aggregate_meter.amr_data)
      summer_holidays.nil? ? :not_enough : :enough
    rescue EnergySparksNotEnoughDataException => _e
      :not_enough
    end
  end

  def self.template_variables
    vars = {'Hot water efficiency' => TEMPLATE_VARIABLES}
    vars.merge!({'Investment table variables' => HotWaterInvestmentAnalysisText.investment_table_template_variables})
    vars.merge!({'Day type breakdown table variables' => HotWaterInvestmentAnalysisText.daytype_table_template_variables})
    vars.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    summer_hot_water_efficiency_chart: {
      description: 'Chart of summer gas consumption before and during summer holidays',
      units: :chart
    },
    investment_choices_table: {
      description: 'Current v. Improved Control v. Point of Use Electric cost-benefit table',
      units: :table,
      header: ['Choice', 'Annual kWh', 'Annual Cost £', 'Annual CO2/kg',
               'Efficiency', 'Saving £', 'Saving £ percent', 'Saving CO2',
               'Saving CO2 percent', 'Capital Cost', 'Payback (years)'],
      column_types: [String, {kwh: :gas}, :£, :co2,
                      :percent, :£, :percent, :co2,
                      :percent, :£, :years],
      data_column_justification: %i[left right right right right right right right right right right]
    },
    daytype_breakdown_table: {
      description: 'School day open v. School day closed v Holidays v Weekends kWh/£ usage',
      units: :table,
      header: ['', 'Average daily kWh', 'Average daily £', 'Annual kWh', 'Annual £'],
      column_types: [String, {kwh: :gas}, :£, {kwh: :gas}, :£],
      data_column_justification: %i[left right right right right]
    },
    theoretical_annual_hot_water_requirement_litres: {
      description: 'Estimate of schools annual hot water requirement in litres',
      units: :litre
    },
    theoretical_annual_hot_water_requirement_kwh: {
      description: 'Estimate of schools annual hot water requirement in kwh if 100% efficient',
      units: { kwh: :gas }
    },
    avg_gas_per_pupil_£: {
      description: 'Annual cost of hot water per pupil (gas)',
      units:          :£,
      benchmark_code: 'ppyr'
    },
    benchmark_existing_gas_efficiency: {
      description: 'Efficiency of existing gas system (percent): for benchmark reporting only',
      units:          :percent,
      benchmark_code: 'eff'
    },
    benchmark_gas_better_control_saving_£: {
      description: 'Saving moving improving gas control: for benchmark reporting only',
      units:          :£,
      benchmark_code: 'gsav'
    },
    benchmark_point_of_use_electric_saving_£: {
      description: 'Saving through moving to POU electric: for benchmark reporting only',
      units:          :£,
      benchmark_code: 'esav'
    },
    electric_hot_water_saving_co2: {
      description: 'CO2 aving through moving to POU electric',
      units:       :co2,
    }
  }

  def summer_hot_water_efficiency_chart
    :hotwater_alert
  end

  # higher rating in summer when user has time to think about hot water versus heating
  def time_of_year_relevance
    set_time_of_year_relevance(@heating_on.nil? ? 5.0 : (@heating_on ? 5.0 : 7.5))
  end

  private def calculate(asof_date)
    calculate_model(asof_date) # so gas_model_only base varaiables are expressed even if no hot water
    if @relevance != :never_relevant && heating_only
      @relevance = :never_relevant
      @rating = nil
    else
      investment = HotWaterInvestmentAnalysisText.new(@school)
      set_tabular_data_as_dynamically_created_attributes(investment.alert_table_data)
      header, rows, totals = investment.investment_table(nil)
      @investment_choices_table = rows

      header, rows, totals = investment.daytype_breakdown_table(nil)
      @daytype_breakdown_table = rows

      @theoretical_annual_hot_water_requirement_litres = investment.annual_litres
      @theoretical_annual_hot_water_requirement_kwh = investment.annual_kwh

      @avg_gas_per_pupil_£ = @existing_gas_annual_£ / @school.number_of_pupils
      @benchmark_existing_gas_efficiency = @existing_gas_efficiency
      @benchmark_gas_better_control_saving_£ = @gas_better_control_saving_£
      @benchmark_point_of_use_electric_saving_£ = @point_of_use_electric_saving_£
      @electric_hot_water_saving_co2 = investment.point_of_use_electric_co2_saving_kg

      @relevance = :relevant

      one_year_saving_£ = one_year_saving_calculation
      capital_costs_£ = @existing_gas_capex..@point_of_use_electric_capex

      assign_commmon_saving_variables(
        one_year_saving_£: one_year_saving_£,
        capital_cost: electric_point_of_use_hotwater_costs,
        one_year_saving_co2: @electric_hot_water_saving_co2)

      @rating = calculate_rating_from_range(0.6, 0.05, @existing_gas_efficiency)

      @term = :shortterm
    end
  end
  alias_method :analyse_private, :calculate

  private def one_year_saving_calculation
    savings = [@gas_better_control_saving_£, @point_of_use_electric_saving_£].sort
    savings[0]..savings[1]
  end

  private def set_tabular_data_as_dynamically_created_attributes(data)
    data.each do |key, value|
      create_and_set_attr_reader(key, value)
    end
  end

  private def create_and_set_attr_reader(key, value)
    self.class.send(:attr_reader, key)
    instance_variable_set("@#{key}", value)
  end
end
