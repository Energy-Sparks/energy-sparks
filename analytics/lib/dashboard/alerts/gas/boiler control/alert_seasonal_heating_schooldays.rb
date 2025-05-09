#======================== Heating on for too many school days of year ==============
require_relative '../alert_gas_model_base.rb'
require_relative './alert_heating_day_base.rb'

# alert for leaving heating on in warm weather
class AlertSeasonalHeatingSchoolDays < AlertHeatingDaysBase
  attr_reader :percent_of_annual_gas, :percent_of_annual_heating
  attr_reader :heating_percent_of_total_gas

  def initialize(school, type = :heating_on_days)
    super(school, type)
    @relevance = :never_relevant if @relevance != :never_relevant && non_heating_only
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def self.template_variables
    specific = {
      'Dynamically seasonal heating statistics' => dynamic_template_variables,
      'Adhoc seasonal heating statistics'      => ADHOC_TEMPLATE_VARIABLES
    }
    specific.merge(self.superclass.template_variables)
  end

  ADHOC_TEMPLATE_VARIABLES = {
    percent_of_annual_gas: {
      description: 'Heating in warm weather as % of annaul total gas usage but use percent_of_annual_heating as better variable',
      units:  :percent
    },
    percent_of_annual_heating: {
      description: 'Percentage of annual heating in warm weather',
      units:  :percent,
      benchmark_code: 'wpan'
    },
    heating_percent_of_total_gas: {
      description: 'Percentage of annual heating of total gas consumption',
      units:  :percent,
    },
    warm_weather_heating_days_adjective: {
      description: 'How many days heating on in warm weather adjective (excellent thru very poor)',
      units:  String
    }
  }

  def time_of_year_relevance
    toy_rating = [9, 10, 11, 4, 5, 6].include?(@asof_date.month) ? 7.5 : 2.5
    set_time_of_year_relevance(toy_rating)
  end

  def heating_on_off_chart
    :heating_on_by_week_with_breakdown
  end

  private def calculate(asof_date)
    calculate_model(asof_date)

    calculate_seasonal_values(asof_date)

    calculate_adhoc_values(asof_date)

    assign_commmon_saving_variables(
      one_year_saving_kwh: warm_weather_heating_days_all_days_kwh,
      one_year_saving_£: warm_weather_heating_days_all_days_£current,
      capital_cost: 0.0,
      one_year_saving_co2: warm_weather_heating_days_all_days_co2)

    @rating = calculate_rating_from_range(0.03, 0.12, percent_of_annual_heating)

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  def warm_weather_heating_days_adjective
    return "" if @warm_weather_heating_days_all_days_days.nil?
    Adjective.warm_weather_on_days_adjective(@warm_weather_heating_days_all_days_days)
  end

  def self.dynamic_template_variables
    heating_types = {
      cold_and_warm_weather_heating_days: %i[heating_cold_weather heating_warm_weather],
      warm_weather_heating_days:          %i[heating_warm_weather],
      hot_water_and_kitchen:              %i[heating_off] # note 'heating off' by default includes hw/kitchen on heating days as split by default in heating model
    }
    day_types = {
      all_days: %i[schoolday weekend holiday],
      schooldays: %i[schoolday],
      non_schooldays: %i[weekend holiday],
    }
    data_types = %i[kwh co2 £ £current days]
    benchmark_codes = {
      warm_weather_heating_days_all_days_kwh:       'wkwh',
      warm_weather_heating_days_all_days_co2:       'wco2',
      warm_weather_heating_days_all_days_£:         'w£__',
      warm_weather_heating_days_all_days_£current:  'w€__',
      warm_weather_heating_days_all_days_days:      'wdys',
    }

    templates = {}

    heating_types.map do |heating_type_name, heating_type_config|
      day_types.map do |day_type_name, day_type_config|
        data_types.map do |data_type|
          key = "#{heating_type_name}_#{day_type_name}_#{data_type}".to_sym

          config = {
            description:    "#{heating_type_name.to_s.humanize} #{day_type_config.map(&:to_s).map(&:humanize).join(' & ')} (#{data_type})",
            units:          data_type,
            calculation:    { heating: heating_type_config, day_type: day_type_config, data_type: data_type},
          }

          config[:benchmark_code] = benchmark_codes[key] if benchmark_codes.key?(key)

          templates[key] = config
        end
      end
    end

    templates
  end

  def calculate_seasonal_values(asof_date)
    self.class.dynamic_template_variables.each do |name, config|
      calc = config[:calculation]
      value = seasonal_value(asof_date, calc[:day_type], calc[:heating], calc[:data_type])
      self.class.send(:attr_reader, name)
      instance_variable_set("@#{name}", value)
    end
  end

  #e.g. date, [:schoolday, :weekend, :holiday], [:heating_warm_weather], :kwh
  def seasonal_value(asof_date, day_types, heating_types, data_type)
    total = 0.0

    analysis = seasonal_analysis(asof_date)

    #e.g. [[:schoolday, :heating_warm_weather], [:weekend, :heating_warm_weather]]
    analysis_types = day_types.product(heating_types)

    analysis_types.each do |(day_type, heating_type)|
      val = analysis.dig(day_type, heating_type, data_type)
      total += val unless val.nil?
    end

    total
  end

  def seasonal_analysis(asof_date)
    @seasonal_analysis ||= @heating_model.heating_on_seasonal_analysis(end_date: asof_date)
  end

  def calculate_adhoc_values(asof_date)
    all_kwh = @cold_and_warm_weather_heating_days_all_days_kwh + @hot_water_and_kitchen_all_days_kwh
    @percent_of_annual_gas = percent(@warm_weather_heating_days_all_days_kwh, all_kwh)
    @percent_of_annual_heating = percent(@warm_weather_heating_days_all_days_kwh, @cold_and_warm_weather_heating_days_all_days_kwh)
    @heating_percent_of_total_gas = @cold_and_warm_weather_heating_days_all_days_kwh / all_kwh
  end
end
