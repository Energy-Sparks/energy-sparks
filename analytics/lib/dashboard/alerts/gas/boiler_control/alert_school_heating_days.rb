#======================== Heating on for too many school days of year ==============
require_relative '../alert_gas_model_base.rb'
require_relative './alert_heating_day_base.rb'

# alerts for leaving the heating on for too long over winter
#
#NOTE: this doesn't seem to be setup in the application, as its not registered
#in the database. Should it be removed?
#Was removed from live system around 2022-04-11
class AlertHeatingOnSchoolDaysDeprecated < AlertHeatingDaysBase

  attr_reader :number_of_heating_days_last_year, :average_number_of_heating_days_last_year
  attr_reader :exemplar_number_of_heating_days_last_year
  attr_reader :heating_day_adjective
  attr_reader :one_year_saving_reduced_days_to_average_kwh, :total_heating_day_kwh
  attr_reader :one_year_saving_reduced_days_to_exemplar_kwh
  attr_reader :one_year_saving_reduced_days_to_average_£, :one_year_saving_reduced_days_to_exemplar_£
  attr_reader :one_year_saving_reduced_days_to_average_co2, :one_year_saving_reduced_days_to_exemplar_co2
  attr_reader :one_year_saving_reduced_days_to_average_percent, :one_year_saving_reduced_days_to_exemplar_percent

  def initialize(school, type = :heating_on_days)
    super(school, type)
    @relevance = :never_relevant if @relevance != :never_relevant && non_heating_only
  end

  def timescale
    '1 year'
  end

  def self.template_variables
    specific = {'Number of heating days in year' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    number_of_heating_days_last_year: {
      description: 'Number of days school days plus non school days when the heating was on',
      units:  :days,
      benchmark_code: 'hdyr'
    },
    average_number_of_heating_days_last_year: {
      description: 'Average number of days in the last year when 30 schools in Energy Sparks left their heating on',
      units:  :days
    },
    exemplar_number_of_heating_days_last_year: {
      description: 'The number of days an exemplar school leaves their heating on',
      units:  :days
    },
    heating_day_adjective: {
      description: 'Adjective describing the schools heating day usage relative to other schools (e.g. average - 9 different adjectives)',
      units:  String
    },
    one_year_saving_reduced_days_to_average_kwh: {
      description: 'Saving through matching average schools heating days (turning off earlier and on later in year, not on holidays, weekends) kWh',
      units:  { kwh: :gas }
    },
    one_year_saving_reduced_days_to_exemplar_kwh: {
      description: 'Saving through matching exemplar schools heating days (turning off earlier and on later in year, not on holidays, weekends) kWh',
      units:  { kwh: :gas }
    },
    one_year_saving_reduced_days_to_average_£: {
      description: 'Saving through matching average schools heating days (turning off earlier and on later in year, not on holidays, weekends) £',
      units:  :£,
      benchmark_code: 'svav'
    },
    one_year_saving_reduced_days_to_exemplar_£: {
      description: 'Saving through matching exemplar schools heating days (turning off earlier and on later in year, not on holidays, weekends) £',
      units:  :£,
      benchmark_code: 'svex'
    },
    one_year_saving_reduced_days_to_average_co2: {
      description: 'Saving through matching average schools heating days (turning off earlier and on later in year, not on holidays, weekends) kg CO2',
      units:  :co2
    },
    one_year_saving_reduced_days_to_exemplar_co2: {
      description: 'Saving through matching exemplar schools heating days (turning off earlier and on later in year, not on holidays, weekends) kg CO2',
      units:  :co2
    },
    one_year_saving_reduced_days_to_average_percent: {
      description: 'Saving through matching average schools heating days (turning off earlier and on later in year, not on holidays, weekends) percent of annual consumption',
      units:  :percent
    },
    one_year_saving_reduced_days_to_exemplar_percent: {
      description: 'Saving through matching exemplar schools heating days (turning off earlier and on later in year, , not on holidays, weekends) percent of annual consumption',
      units:  :percent,
      benchmark_code: 'svep'
    },
    total_heating_day_kwh: {
      description: 'Total heating day kWh',
      units:  { kwh: :gas }
    },
    heating_on_off_chart: {
      description: 'heating on off weekly chart',
      units:  :chart
    },
  }

  def time_of_year_relevance
    toy_rating = [10, 11, 4, 5, 6].include?(@asof_date.month) ? 7.5 : 2.5
    set_time_of_year_relevance(toy_rating)
  end

  def heating_on_off_chart
    :heating_on_by_week_with_breakdown
  end

  private def calculate(asof_date)
    calculate_model(asof_date)
    statistics = AnalyseHeatingAndHotWater::HeatingModel # alias long name
    @breakdown = heating_day_breakdown_current_year(asof_date)

    analysis = @heating_model.heating_on_seasonal_analysis

    @exemplar_number_of_heating_days_last_year = 90

    days = school_days_heating
    @number_of_heating_days_last_year = days

    @average_number_of_heating_days_last_year = statistics.average_school_heating_days
    @heating_day_adjective = statistics.school_heating_day_adjective(days)

    @one_year_saving_reduced_days_to_average_kwh, @total_heating_day_kwh = calculate_heating_on_statistics(asof_date, days, @average_number_of_heating_days_last_year)
    @one_year_saving_reduced_days_to_average_percent = @one_year_saving_reduced_days_to_average_kwh / @total_heating_day_kwh

    @one_year_saving_reduced_days_to_exemplar_kwh, _total_kwh = calculate_heating_on_statistics(asof_date, days, @exemplar_number_of_heating_days_last_year)
    @one_year_saving_reduced_days_to_exemplar_percent = @one_year_saving_reduced_days_to_exemplar_kwh / @total_heating_day_kwh

    @one_year_saving_reduced_days_to_average_£  = gas_cost(@one_year_saving_reduced_days_to_average_kwh)
    @one_year_saving_reduced_days_to_exemplar_£ = gas_cost(@one_year_saving_reduced_days_to_exemplar_kwh)

    @one_year_saving_reduced_days_to_average_co2 = gas_co2(@one_year_saving_reduced_days_to_average_kwh)
    @one_year_saving_reduced_days_to_exemplar_co2 = gas_co2(@one_year_saving_reduced_days_to_exemplar_kwh)

    one_year_saving_£ = Range.new(@one_year_saving_reduced_days_to_average_£, @one_year_saving_reduced_days_to_exemplar_£)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @one_year_saving_reduced_days_to_exemplar_kwh,
      one_year_saving_£: one_year_saving_£,
      one_year_saving_co2: @one_year_saving_reduced_days_to_exemplar_co2)

    @rating = statistics.school_day_heating_rating_out_of_10(days)

    @status = @rating < 5.0 ? :bad : :good

    @term = :longterm
  end
  alias_method :analyse_private, :calculate
end
