#================= Base Class for Gas Alerts including model usage=============
require_relative 'alert_gas_only_base.rb'
require_relative 'alert_model_cache_mixin.rb'

class AlertGasModelBase < AlertGasOnlyBase
  include Logging
  include AlertModelCacheMixin
  MAX_CHANGE_IN_PERCENT = 0.15

  attr_reader :enough_data

  attr_reader :heating_model

  def initialize(school, _report_type)
    super(school, _report_type)
    @heating_model = nil
    @breakdown = nil
  end

  def schoolday_energy_usage_over_period(asof_date, school_days)
    total_kwh = 0.0
    while school_days > 0
      unless @school.holidays.holiday?(asof_date) || asof_date.saturday? || asof_date.sunday?
        total_kwh += days_energy_consumption(asof_date)
        school_days -= 1
      end
      asof_date -= 1
    end
    [asof_date, total_kwh]
  end

  def self.template_variables
    specific = {'Gas Model' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    enough_data: {
      description: 'Enough data for heating model calculation',
      units:  TrueClass
    },
    a: {
      description: 'Average heating model regression parameter a',
      units:  :kwh_per_day
    },
    b: {
      description: 'Average heating model regression parameter b',
      units: :kwh_per_day_per_c
    },
    school_days_heating: {
      description: 'Number of school days of heating in the last year',
      units:  :days
    },
    school_days_heating_adjective: {
      description: 'Number of school heating days adjective (above, below average etc.)',
      units: String
    },
    school_days_heating_rating_out_of_10: {
      description: 'Number of school heating rating out of 10',
      units: Integer
    },
    average_school_heating_days: {
      description: 'Average number of school days for all schools have heating on during a year',
      units: Integer
    },
    non_school_days_heating: {
      description: 'Number of weekend, holiday days of heating in the last year',
      units:  :days
    },
    non_school_days_heating_adjective: {
      description: 'Weekend, holiday heating days adjective (above, below average etc.)',
      units: String
    },
    non_school_days_heating_rating_out_of_10: {
      description: 'Weekend, holiday heating day rating out of 10',
      units: Integer
    },
    average_non_school_day_heating_days: {
      description: 'Average weekend, holiday heating for all schools days during a year',
      units: Integer
    }
  }.freeze

  protected def days_energy_consumption(date)
    amr_data = aggregate_meter.amr_data
    amr_data.one_day_kwh(date)
  end

  def a
    @a ||= @heating_model&.average_heating_school_day_a
  end

  def b
    @b ||= @heating_model&.average_heating_school_day_b
  end

  def school_days_heating
    @school_days_heating ||= @heating_model&.number_of_heating_school_days
  end

  def school_days_heating_adjective
    AnalyseHeatingAndHotWater::HeatingModel.school_heating_day_adjective(school_days_heating)
  end

  def school_days_heating_rating_out_of_10
    AnalyseHeatingAndHotWater::HeatingModel.school_day_heating_rating_out_of_10(school_days_heating)
  end

  def average_school_heating_days
    AnalyseHeatingAndHotWater::HeatingModel.average_school_heating_days
  end

  def non_school_days_heating
    @non_school_days_heating ||= @heating_model&.number_of_non_school_heating_days
  end

  def non_school_days_heating_adjective
    AnalyseHeatingAndHotWater::HeatingModel.non_school_heating_day_adjective(non_school_days_heating)
  end

  def non_school_days_heating_rating_out_of_10
    AnalyseHeatingAndHotWater::HeatingModel.non_school_day_heating_rating_out_of_10(non_school_days_heating)
  end

  def average_non_school_day_heating_days
    AnalyseHeatingAndHotWater::HeatingModel.average_non_school_day_heating_days
  end

  protected def enough_data_for_model_fit(asof_date = @asof_date)
    # not sure caching is right here potentially for mismatch on asof_dates in analytics testing
    @heating_model = calculate_model(asof_date) if @heating_model.nil?
    @heating_model.enough_samples_for_good_fit
  rescue EnergySparksNotEnoughDataException, NoMethodError => e
    false
  end

  def time_of_year_relevance
    set_time_of_year_relevance(@heating_on.nil? ? 5.0 : (@heating_on ? 7.5 : 2.5))
  end

  protected def calculate_model(asof_date)
    @heating_model = model_cache(aggregate_meter, asof_date)
    @heating_on = @heating_model.heating_on?(asof_date)
    @heating_model
  end
end
