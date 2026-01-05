require 'active_support/core_ext/string/filters' # for string.truncate
# Alerts: Energy Sparks alerts
#         this is a mix of short-term alerts e.g. your energy consumption has gone up since last week
#         and longer term alerts - energy assessments e.g. your energy consumption at weekends it high
#
# the current code strcucture consists of an alert base class from which individual classes analysing
# different aspect of energy consumption are derived
#
# plus a reporting class for alerts which can return a mixture of text, html, charts etc., although
# much of the potential complexity of this framework will not be implemented in the first iteration
class AlertAnalysisBase < ContentBase
  include Logging

  ALERT_HELP_URL = 'https://blog.energysparks.uk/alerts'.freeze

  attr_reader :status, :rating, :term, :default_summary, :default_content
  attr_reader :analysis_date, :max_asofdate, :calculation_worked

  attr_reader :capital_cost, :one_year_saving_£, :ten_year_saving_£, :payback_years
  attr_reader :one_year_saving_co2, :ten_year_saving_co2
  attr_reader :one_year_saving_kwh
  attr_reader :average_capital_cost, :average_one_year_saving_£, :average_payback_years
  attr_reader :average_ten_year_saving_£
  attr_reader :error_message, :backtrace

  attr_reader :time_of_year_relevance

  def initialize(school, _report_type)
    super(school)
    @capital_cost = 0.0..0.0
    clear_model_cache
  end

  def analyse(asof_date, use_max_meter_date_if_less_than_asof_date = false, **kwargs)
    begin
      @asof_date = asof_date
      @max_asofdate = maximum_alert_date
      if valid_alert?
        date = use_max_meter_date_if_less_than_asof_date ? [maximum_alert_date, asof_date].min : asof_date

        if @analysis_date.nil? || @analysis_date != date # only call once per date
          @analysis_date = date
          calculate(@analysis_date)
        end
      end
    rescue EnergySparksNotEnoughDataException => e
      log_stack_trace(e, false)
      @not_enough_data_exception = true # TODO(PH, 31Jul2019) a mess for the moment, needs rationalising
    rescue EnergySparksCalculationException => e
      # LD(2022-08-23) add handler for custom exception so we can highlight problems
      Rollbar.warning(e, alert_type: self.class.name, asof_date: asof_date, school: @school.name)
      log_stack_trace(e)
      @calculation_worked = false
    rescue StandardError => e
      log_stack_trace(e)
      Rollbar.warning(e, alert_type: self.class.name, asof_date: asof_date, school: @school.name) if ENV["LOG_ALL_ANALYTICS_ERRORS"] == 'true'
      @calculation_worked = false
    end
  end

  def self.test_mode
    !Object.const_defined?('Rails')
    # !ENV['ENERGYSPARKSTESTMODE'].nil? && ENV['ENERGYSPARKSTESTMODE'] == 'ON'
  end

  def log_stack_trace(e, backtrace = true)
    @error_message = e.message
    @backtrace = e.backtrace

    logger.warn e.message.truncate(120)
    logger.warn e.backtrace[..5] if backtrace
  end

  private def exclude_backtrace?(message)
    [
      'Not enough samples for model to provide good regression fit',
      'Not enough data: 1 year of data required',
      'Not enough data: 2 years of data required'
    ].any?{ |exclude| message.include?(exclude) }
  end

  def benchmark_dates(asof_date)
    [asof_date]
  end

  # inherited, so derived class has hash of 'name' => variables
  def self.template_variables
    { 'Common' => TEMPLATE_VARIABLES }
  end

  def summary_wording(format = :html)
    return nil if default_summary.nil? # remove once all new style alerts implemeted TODO(PH,13Mar2019)
    summary = AlertTemplateBinding.new(default_summary, formatted_template_variables(format), format)
    summary.bind
  end

  def content_wording(format = :html)
    return nil if default_content.nil? # remove once all new style alerts implemeted TODO(PH,13Mar2019)
    content = AlertTemplateBinding.new(default_content, formatted_template_variables(format), format)
    content.bind
  end

  TEMPLATE_VARIABLES = {
    relevance: {
      description: 'Relevance of a alert to a school at this point in time',
      units:  :relevance
    },
    analysis_date: {
      description: 'Latest date on which the alert data is based',
      units:  :date
    },
    status: {
      description: 'Status: good, bad, failed',
      units:  Symbol
    },
    rating: {
      description: 'Rating out of 10',
      units:  Float,
      priority_code:  'RATE',
      benchmark_code: 'ratg'
    },
    term: {
      description: 'long term or short term',
      units:  Symbol
    },
    max_asofdate: {
      description: 'The latest date on which an alert can be run given the available data',
      units:  :date
    },
    pupils: {
      description: 'Number of pupils for relevant part of school on this date',
      units:  Integer
    },
    floor_area: {
      description: 'Floor area of relevant part of school',
      units:  :m2
    },
    school_type: {
      description: 'Primary or Secondary',
      units:  :school_type
    },
    school_name: {
      description: 'Name of school',
      units: String
    },
    school_activation_date: {
      description: 'Date school activated on Energy Sparks',
      units: Date
    },
    school_creation_date: {
      description: 'Date school created on Energy Sparks',
      units: Date
    },
    urn: {
      description: 'School URN',
      units:  Integer
    },
    one_year_saving_kwh: {
      description: 'Estimated one year kwh reduction range',
      units: :kwh
    },
    one_year_saving_£: {
      description: 'Estimated one year saving range',
      units: :£_range
    },
    one_year_saving_co2: {
      description: 'Estimated one year saving co2',
      units: :co2
    },
    ten_year_saving_co2: {
      description: 'Estimated ten year saving co2',
      units: :co2
    },
    average_one_year_saving_£: {
      description: 'Estimated one year saving range',
      units: :£,
      priority_code:  '1YRS',
      # benchmark_code: '1yrsav_£'
    },
    average_ten_year_saving_£: {
      description: 'Estimated ten year saving range',
      units: :£,
      priority_code:  '10YR'
    },
    ten_year_saving_£: {
      description: 'Estimated ten year saving range - typical capital investment horizon',
      units: :£_range
    },
    payback_years: {
      description: 'Payback in years',
      units: :years_range
    },
    average_payback_years: {
      description: 'Average payback in years',
      units: :years,
      priority_code:  'PAYB'
    },
    capital_cost: {
      description: 'Capital cost',
      units: :£_range,
    },
    average_capital_cost: {
      description: 'Average Capital cost',
      units: :£,
      priority_code:  'CAPC'
    },
    timescale: {
      description: 'Timescale of analysis e.g. week, month, year',
      units: String
    },
    time_of_year_relevance: {
      description: 'Rating: 10 = relevant to time of year, 0 = irrelevant, 5 = average/normal',
      units: Float,
      priority_code:  'TYRL'
    }
  }.freeze

  def maximum_alert_date
    raise EnergySparksAbstractBaseClass.new('Error: incorrect attempt to use abstract base class ' + self.class.name)
  end

  def timescale
    #TODO this probably unneeded as the text returned can be dynamically looked up
    #from the YAML file based on class name
    raise EnergySparksAbstractBaseClass.new('Error: incorrect attempt to use abstract base class for timeescale template variable ' + self.class.name)
  end

  def time_of_year_relevance
    set_time_of_year_relevance(5.0)
    # TODO(PH, 26Aug2019) - remove return in favour of raise once all derived classes defined
    # raise EnergySparksAbstractBaseClass, "Error: incorrect attempt to use abstract base class for time_of_year_relevance template variable #{self.class.name}"
  end

  def valid_alert?
    valid_content? && meter_readings_up_to_date_enough?
  end

  #unused method?
  def self.print_all_formatted_template_variable_values
    puts 'Available variables and values:'
    self.template_variables.each do |group_name, variable_group|
      puts "  #{group_name}"
      variable_group.each do |type, data|
        # next if data[:units] == :table
        value = send(type)
        formatted_value = format(data[:units], value, :html, false, user_numeric_comprehension_level)
        puts sprintf('    %-40.40s %-20.20s', type, formatted_value) + ' ' + data.to_s
      end
    end
  end

  protected

  def set_time_of_year_relevance(weight)
    @time_of_year_relevance = weight
  end

  def add_book_mark_to_base_url(bookmark)
    @help_url = ALERT_HELP_URL + '#' + bookmark
  end

  def assign_commmon_saving_variables(one_year_saving_kwh: nil, one_year_saving_£:, capital_cost: nil, one_year_saving_co2:)
    @one_year_saving_£ = as_range(one_year_saving_£)
    @ten_year_saving_£ = @one_year_saving_£.nil? ? 0.0 : Range.new(@one_year_saving_£.first * 10.0, @one_year_saving_£.last * 10.0)

    @average_one_year_saving_£ = @one_year_saving_£.nil? ? 0.0 : ((@one_year_saving_£.first + @one_year_saving_£.last) / 2.0)
    @average_ten_year_saving_£ = @average_one_year_saving_£ * 10.0

    @one_year_saving_co2 = one_year_saving_co2
    @ten_year_saving_co2 = one_year_saving_co2 * 10.0

    @one_year_saving_kwh = one_year_saving_kwh

    @capital_cost = as_range(capital_cost)
    @average_capital_cost = @capital_cost.nil? ? 0.0 : ((@capital_cost.first + @capital_cost.last)/ 2.0)
    @average_payback_years = @average_one_year_saving_£ == 0.0 ? 0.0 : @average_capital_cost / @average_one_year_saving_£
  end

  private def as_range(value)
    value.is_a?(Float) ? Range.new(value, value) : value
  end

  def pupils
    if @school.respond_to?(:number_of_pupils) && @school.number_of_pupils > 0
      @school.number_of_pupils
    elsif @school.respond_to?(:school) && !@school.school.number_of_pupils > 0
      @school.school.number_of_pupils
    else
      raise EnergySparksBadDataException.new('Unable to find number of pupils for alerts')
    end
  end

  def floor_area
    if @school.respond_to?(:floor_area) && !@school.floor_area.nil? && @school.floor_area > 0.0
      @school.floor_area
    elsif @school.respond_to?(:school) && !@school.school.floor_area.nil? && @school.school.floor_area > 0.0
      @school.school.floor_area
    else
      raise EnergySparksBadDataException.new('Unable to find number of floor_area for alerts')
    end
  end

  def school_activation_date
    @school.activation_date
  end

  def school_creation_date
    @school.creation_date
  end

  def school_name
    if @school.respond_to?(:name) && !@school.name.nil?
      @school.name
    elsif @school.respond_to?(:name) && !@school.school.name.nil?
      @school.school.name
    else
      raise EnergySparksBadDataException.new('Unable to find school name for alerts')
    end
  end

  def urn
    @school.urn
  end

  def activation_date
    @school.activation_date
  end

  def creation_date
    @school.creation_date
  end

  def school_type
    if @school.respond_to?(:school_type) && !@school.school_type.nil?
      @school.school_type.instance_of?(String) ? @school.school_type.to_sym : @school.school_type
    elsif @school.respond_to?(:school) && !@school.school.school_type.nil?
      @school.school.school_type.instance_of?(String) ? @school.school.school_type.to_sym : @school.school.school_type
    else
      raise EnergySparksBadDataException.new("Unable to find number of school_type for alerts #{@school.school_type} #{@school.school.school_type}")
    end
  end

  protected def holiday?(date)
    @school.holidays.holiday?(date)
  end

  protected def weekend?(date)
    date.saturday? || date.sunday?
  end

  protected def occupied?(date)
    !(weekend?(date) || holiday?(date))
  end

  protected def occupancy_description(date)
    holiday?(date) ? I18n.t('analytics.common.holiday') : weekend?(date) ? I18n.t('analytics.common.weekend') : I18n.t('analytics.common.school_day')
  end

  # returns a list of the last n 'school_days' before and including the asof_date
  def last_n_school_days(asof_date, school_days)
    list_of_school_days = []
    while school_days > 0
      if occupied?(asof_date)
        list_of_school_days.push(asof_date)
        school_days -= 1
      end
      asof_date -= 1
    end
    list_of_school_days.sort
  end

  protected def meter_date_up_to_one_year_before(meter, asof_date)
    [asof_date - 365, meter.amr_data.start_date].max
  end

  protected def kwh_date_range(meter, start_date, end_date, data_type = :kwh, community_use: nil)
    return nil if meter.amr_data.start_date > start_date || meter.amr_data.end_date < end_date
    meter.amr_data.kwh_date_range(start_date, end_date, data_type, community_use: community_use)
  end

  protected def kwhs_date_range(meter, start_date, end_date, data_type = :kwh, min_days_data = nil, community_use: nil)
    if min_days_data.nil?
      return nil if meter.amr_data.start_date > start_date || meter.amr_data.end_date < end_date
      (start_date..end_date).to_a.map { |date| meter.amr_data.one_day_kwh(date, data_type, community_use: community_use) }
    else
      sd = [meter.amr_data.start_date, start_date].max
      ed = [meter.amr_data.end_date  , end_date].min
      days = ed - sd + 1
      if (meter.amr_data.start_date > start_date || meter.amr_data.end_date < end_date) && days < min_days_data
        nil
      else
        (sd..ed).to_a.map { |date| meter.amr_data.one_day_kwh(date, data_type, community_use: community_use) }
      end
    end
  end

  protected def kwh(date1, date2, data_type = :kwh)
    aggregate_meter.amr_data.kwh_date_range(date1, date2, data_type)
  end

  protected def meter_date_one_year_before(meter, asof_date)
    meter_date_up_to_one_year_before(meter, asof_date)
  end

  protected def annual_kwh(meter, asof_date)
    start_date = meter_date_one_year_before(meter, asof_date)
    kwh(start_date, asof_date) * scale_up_to_one_year(meter, asof_date)
  end

  protected def calculate_up_to_annual_kwh(meter, asof_date)
    start_date = meter_date_one_year_before(meter, asof_date)
    kwh(start_date, asof_date)
  end

  protected def scale_up_to_one_year(meter, asof_date)
    365.0 / (asof_date - meter_date_one_year_before(meter, asof_date))
  end

  #TEMPORARY
  #As part of the localisation refactor some instance variables produced in the calculate
  #methods were moved to being returned by instance variables.
  #
  #This means that previously, where calculating the values of those variables may have caused
  #an exception (e.g. attempting to determine an adjective for a nil value), the calculate
  #method may continue and even complete.
  #
  #To avoid generating ratings for alerts that may have been previously (silently) failing
  #for some schools, this method is provided to raise an error for those exceptions
  #
  #This is intended to give us some insights into which alerts/schools might be failing and
  #so we can act on it. E.g. by adding in better preconditions to the calculate method
  protected def raise_calculation_error_if_missing(variables)
    missing = variables.entries.select{|k,v| v.nil? }
    raise EnergySparksCalculationException.new("#{missing.map{|m| m[0]}.join(",")} are missing") if missing.any?
  end

  private

  def calculate(asof_date)
    raise EnergySparksAbstractBaseClass, 'Error: incorrect attempt to use abstract base class'
  end

  def relative_change(difference, base)
    if difference == 0.0 && base == 0.0
      0.0
    elsif base == 0.0
      Float::INFINITY
    else
      difference / base
    end
  end

  # the model cache cached at the aggregate meter and therefore the school level
  # if in the analystics enronment we are running slightly different (asof_date v. chart_date)
  # then clear the cache, however, then does further caching if in 'test' mode
  private def clear_model_cache
    @school.aggregated_heat_meters.model_cache.clear_model_cache unless @school.aggregated_heat_meters.nil?
  end

  public

  # slightly iffy way of creating short codes for alert class names
  def self.alert_short_code(alert_class)
    alert_class.to_s.split(//).select { |char| ('A'..'Z').cover?(char) }[1..8].join
  end

  def self.short_code_alert(short_code)
    matching_alerts = all_available_alerts.select { |available_alert| alert_short_code(available_alert) == short_code }
    raise EnergySparksUnexpectedStateException, "Only expected one matching short code for #{short_code}, got #{matching_alerts.length}" if matching_alerts.length != 1
    matching_alerts.first
  end

  class UnknownFuelTypeForBenchmarkAlert < StandardError; end

  def self.benchmark_alert(school, fuel_type, asof_date)
    alert_class = case fuel_type
                  when :electricity
                    AlertElectricityAnnualVersusBenchmark
                  when :gas
                    AlertGasAnnualVersusBenchmark
                  when :storage_heater
                    AlertStorageHeaterAnnualVersusBenchmark
                  else
                    raise UnknownFuelTypeForBenchmarkAlert, "Unknown benchmark fuel type #{fuel_type}"
                  end

    alert = alert_class.new(school)

    asof_date = [asof_date, alert.aggregate_meter.amr_data.end_date].min

    alert.analyse(asof_date)
    alert
  end

  def self.out_of_hours_alert(school, fuel_type, asof_date)
    alert_class = case fuel_type
                  when :electricity
                    AlertOutOfHoursElectricityUsage
                  when :gas
                    AlertOutOfHoursGasUsage
                  when :storage_heater
                    AlertStorageHeaterOutOfHours
                  else
                    raise UnknownFuelTypeForBenchmarkAlert, "Unknown out of hours fuel type #{fuel_type}"
                  end


    alert = alert_class.new(school)

    asof_date = [asof_date, alert.aggregate_meter.amr_data.end_date].min

    alert.analyse(asof_date)

    alert
  end

  def self.all_alerts
    {
      AlertChangeInDailyElectricityShortTerm                      => 'elst',
      AlertChangeInDailyGasShortTerm                              => 'gsst',
      AlertChangeInElectricityBaseloadShortTerm                   => 'elbc',
      AlertEnergyAnnualVersusBenchmark                            => 'enba',
      AlertElectricityAnnualVersusBenchmark                       => 'elba',
      AlertElectricityBaseloadVersusBenchmark                     => 'elbb',
      AlertGasAnnualVersusBenchmark                               => 'gsba',
      AlertHeatingComingOnTooEarly                                => 'hthe',
      AlertHeatingSensitivityAdvice                               => 'htsa',
      AlertHotWaterEfficiency                                     => 'hotw',
      AlertImpendingHoliday                                       => 'ihol',
#       AlertHeatingOnNonSchoolDays                                 => 'htns', deprecated
      AlertOutOfHoursElectricityUsage                             => 'eloo',
      AlertOutOfHoursElectricityUsagePreviousYear                 => 'elop',
      AlertOutOfHoursGasUsage                                     => 'gsoo',
      AlertOutOfHoursGasUsagePreviousYear                         => 'gsop',
      AlertHotWaterInsulationAdvice                               => 'hwia',
#      AlertHeatingOnSchoolDays                                    => 'htsd', deprecated
      AlertThermostaticControl                                    => 'httc',
      AlertWeekendGasConsumptionShortTerm                         => 'gswe',
      AlertMeterASCLimit                                          => 'masc',
      AlertSchoolWeekComparisonElectricity                        => 'eswc',
      AlertPreviousHolidayComparisonElectricity                   => 'ephc',
      AlertPreviousYearHolidayComparisonElectricity               => 'epyc',
      AlertSchoolWeekComparisonGas                                => 'gswc',
      AlertPreviousHolidayComparisonGas                           => 'gphc',
      AlertPreviousYearHolidayComparisonGas                       => 'gpyc',
      AlertPreviousYearHolidayComparisonStorageHeater             => 'spyc',
      AlertAdditionalPrioritisationData                           => 'addp',
      AlertElectricityPeakKWVersusBenchmark                       => 'epkb',
      AlertStorageHeaterAnnualVersusBenchmark                     => 'shan',
      AlertStorageHeaterThermostatic                              => 'shtc',
      AlertStorageHeaterOutOfHours                                => 'shoo',
      AlertOutOfHoursStorageHeaterUsagePreviousYear               => 'shop',
#      AlertHeatingOnSchoolDaysStorageHeaters                      => 'shhd', deprecated
      AlertSolarPVBenefitEstimator                                => 'sole',
      AlertElectricityLongTermTrend                               => 'ellt',
      AlertGasLongTermTrend                                       => 'gslt',
      AlertStorageHeatersLongTermTrend                            => 'shlt',
      AlertOptimumStartAnalysis                                   => 'opts',
      AlertSummerHolidayRefrigerationAnalysis                     => 'free',
      AlertElectricityTargetAnnual                                => 'etga',
      AlertGasTargetAnnual                                        => 'gtga',
      AlertElectricityTarget4Week                                 => 'etg4',
      AlertGasTarget4Week                                         => 'gtg4',
      AlertElectricityTarget1Week                                 => 'etg1',
      AlertGasTarget1Week                                         => 'gtg1',
      AlertSeasonalBaseloadVariation                              => 'sblv',
      AlertIntraweekBaseloadVariation                             => 'iblv',
      AlertGasHeatingHotWaterOnDuringHoliday                      => 'hdhl',
      AlertStorageHeaterHeatingOnDuringHoliday                    => 'shoh',
      AlertCommunitySchoolWeekComparisonElectricity               => 'cswe',
      AlertCommunitySchoolWeekComparisonGas                       => 'cswg',
      AlertCommunityPreviousHolidayComparisonElectricity          => 'cphe',
      AlertCommunityPreviousHolidayComparisonGas                  => 'cphg',
      AlertCommunityPreviousYearHolidayComparisonElectricity      => 'cpye',
      AlertCommunityPreviousYearHolidayComparisonGas              => 'cpyg',
      AlertTurnHeatingOff                                         => 'htof',
      AlertSeasonalHeatingSchoolDays                              => 'shsd',
      AlertSeasonalHeatingSchoolDaysStorageHeaters                => 'shsh',
      AlertTurnHeatingOffStorageHeaters                           => 'tosh',
      AlertElectricityUsageDuringCurrentHoliday                   => 'edhl',
      AlertSchoolWeekComparisonStorageHeater                      => 'sswc',
      AlertSolarGeneration                                        => 'sgen'
    }
  end

  def self.short_code
    all_alerts[self]
  end

  def self.all_available_alerts
    all_alerts.keys
  end

end
