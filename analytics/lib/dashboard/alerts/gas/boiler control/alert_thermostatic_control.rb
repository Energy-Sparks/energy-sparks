#======================== Poor thermostatic control ==============
require_relative '../alert_gas_model_base.rb'

class AlertThermostaticControl < AlertGasModelBase
  MIN_R2 = 0.8

  attr_reader :r2_rating_out_of_10, :potential_saving_kwh, :potential_saving_£, :potential_saving_co2

  def initialize(school, type = :thermostaticcontrol)
    super(school, type)
    @relevance = :never_relevant if @relevance != :never_relevant && non_heating_only
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    enough_data_for_model_fit ? :enough : :not_enough
  end

  def self.template_variables
    specific = {'Thermostatic Control' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    r2: {
      description: 'Average heating model regression parameter thermostatic control r2',
      units: :r2,
      benchmark_code: 'r2'
    },
    average_schools_r2: {
      description: 'Average heating r2 of all schools',
      units: :r2
    },
    r2_rating_adjective: {
      description: 'Average heating model regression parameter thermostatic control r2 adjective',
      units: String
    },
    r2_rating_out_of_10: {
      description: 'Average heating model regression parameter thermostatic control r2 rating out of 10',
      units: Float
    },
    base_temperature: {
      description: 'Average base temperature for heating model',
      units: :temperature
    },
    thermostatic_chart: {
      description: 'Simplified version of relevant thermostatic chart',
      units: :chart
    },
    potential_saving_kwh: {
      description: 'Potential savings kWh through perfect themostatic control',
      units: { kwh: :gas}
    },
    potential_saving_£: {
      description: 'Potential savings £ through perfect themostatic control',
      units: :£,
      benchmark_code: 'sav€'
    },
    potential_saving_co2: {
      description: 'Potential savings co2 through perfect themostatic control',
      units: :co2,
    }
  }.freeze

  def thermostatic_chart
    :thermostatic
  end

  def r2
    @r2 ||= @heating_model.average_heating_school_day_r2
  end

  def r2_rating_adjective
    AnalyseHeatingAndHotWater::HeatingModel.r2_rating_adjective(r2)
  end

  def average_schools_r2
    AnalyseHeatingAndHotWater::HeatingModel.average_schools_r2
  end

  def r2_rating_out_of_10
    AnalyseHeatingAndHotWater::HeatingModel.r2_rating_out_of_10(r2)
  end

  def base_temperature
    @base_temperature ||= @heating_model.average_base_temperature
  end

  def time_of_year_relevance
    set_time_of_year_relevance(@heating_on.nil? ? 5.0 : (@heating_on ? 7.5 : 0.0))
  end

  private def calculate(asof_date)
    calculate_model(asof_date)

    @potential_saving_kwh, @potential_saving_£ = calculate_annual_heating_deviance_from_model(asof_date)
    @potential_saving_co2 = gas_co2(@potential_saving_kwh)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @potential_saving_kwh,
      one_year_saving_£: @potential_saving_£,
      capital_cost: 1000.0,
      one_year_saving_co2: @potential_saving_co2) # suggested £1,000 cost

    @rating = r2_rating_out_of_10

    @status = @rating < 5.0 ? :bad : :good

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  # crudely assess the potential saving as the difference between actual and predicted
  # multiplied by the difference in the r2 to perfect 1.0, for the moment (PH, 27Aug2019)
  private def calculate_annual_heating_deviance_from_model(asof_date)
    potential_saving_kwh = 0.0
    potential_saving_£ = 0.0
    start_date = meter_date_up_to_one_year_before(aggregate_meter, asof_date)

    (start_date..asof_date).each do |date|
      if @heating_model.heating_on?(date)
        avg_temperature = @school.temperatures.average_temperature(date)
        predicted_kwh = [@heating_model.predicted_kwh(date, avg_temperature), 0.0].max # not -tve - fudge e.g. Whiteways holiday heating model producing spurious output
        actual_kwh = kwh(date, date)
        loss_versus_predicted_kwh = actual_kwh - predicted_kwh
        potential_saving_kwh += loss_versus_predicted_kwh.magnitude # use absolute value for want of any other basis for the moment (PH, 27Aug2019)
        potential_saving_£ += loss_versus_predicted_kwh.magnitude * aggregate_meter.amr_data.current_tariff_rate_£_per_kwh
      end
    end
    [potential_saving_kwh * (1.0 - r2), potential_saving_£ * (1.0 - r2)]
  end
end
