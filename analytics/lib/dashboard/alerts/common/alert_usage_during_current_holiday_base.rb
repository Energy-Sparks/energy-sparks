# frozen_string_literal: true

# During holidays alert schools if they are consuming energy
class AlertUsageDuringCurrentHolidayBase < AlertAnalysisBase
  USAGE_THRESHOLD_£ = 10.0
  attr_reader :holiday_usage_to_date_kwh, :holiday_projected_usage_kwh, :holiday_usage_to_date_£, :holiday_projected_usage_£, :holiday_usage_to_date_co2, :holiday_projected_usage_co2

  def initialize(school, report_type)
    super(school, report_type)
    @rating = 10.0
    @relevance = :never_relevant unless holiday?(@today)
  end

  def self.template_variables
    specific = { 'Electricity usage during current holiday' => TEMPLATE_VARIABLES }
    specific.merge(superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    holiday_name: {
      description: 'Name of holiday',
      units: String,
      benchmark_code: 'hnam'
    },
    holiday_type: {
      description: 'Type of holiday',
      units: String
    },
    holiday_start_date: {
      description: 'Start date of holiday',
      units: :date
    },
    holiday_end_date: {
      description: 'End date of holiday',
      units: :date
    },
    holiday_usage_to_date_kwh: {
      description: 'Usage so far this holiday - kwh',
      units: :kwh
    },
    holiday_projected_usage_kwh: {
      description: 'Projected usage for whole holiday - kwh',
      units: :kwh
    },
    holiday_usage_to_date_£: {
      description: 'Usage so far this holiday - £',
      units: :£,
      benchmark_code: '£sfr'
    },
    holiday_projected_usage_£: {
      description: 'Projected usage for whole holiday - £',
      units: :£,
      benchmark_code: '£pro'
    },
    holiday_usage_to_date_co2: {
      description: 'Usage so far this holiday - co2',
      units: :co2
    },
    holiday_projected_usage_co2: {
      description: 'Projected usage for whole holiday - co2',
      units: :co2
    },
    summary: {
      description: 'Summary of holiday usage',
      units: String
    },
    fuel_type: {
      description: 'Fuel: gas, electricity or storage heaters',
      units: :fuel_type
    },
    heating_type: {
      description: 'gas boiler or storage heaters, or nil',
      units: String,
      benchmark_code: 'ftyp'
    }
  }.freeze

  # We have enough data so long as there is some recorded usage within the current holiday
  def enough_data
    holiday_period = @school.holidays.holiday(@today)
    if !holiday_period.nil? &&
       aggregate_meter.amr_data.start_date <= holiday_period.start_date &&
       aggregate_meter.amr_data.end_date   >= holiday_period.start_date
      :enough
    else
      :not_enough
    end
  end

  def time_of_year_relevance
    set_time_of_year_relevance(@relevance == :relevant ? 10.0 : 0.0)
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def heating_type
    nil
  end

  def maximum_alert_date
    aggregate_meter.amr_data.end_date
  end

  def fuel_type
    raise 'Subclass must implement'
  end

  def reporting_period
    :current_holidays
  end

  protected

  def max_days_out_of_date_while_still_relevant
    14
  end

  def aggregate_meter
    raise 'Subclass must implement'
  end

  private

  # Calculate will only be called if this is a +valid_alert?+ which is only true if we
  # are currently within a holiday (@relevance) and we have the necessary aggregate
  # meter
  def calculate(asof_date)
    @holiday_period     = @school.holidays.holiday(asof_date)
    holiday_date_range  = @holiday_period.start_date..@holiday_period.end_date

    # Calculate summary of usage by day type
    usage_to_date  = calculate_usage_to_date(holiday_date_range)

    # Calculate total usage across both day types
    totals_to_date = totals(usage_to_date)

    @holiday_usage_to_date_kwh   = totals_to_date[:kwh]
    @holiday_usage_to_date_£   = totals_to_date[:£]
    @holiday_usage_to_date_co2   = totals_to_date[:co2]

    # Calculate number of work and weekend days in holiday as a whole
    workdays_days, weekend_days = holiday_weekday_workday_stats(holiday_date_range)
    # Project usage for the entire holiday, based on current usage
    projected_totals = calculate_projected_totals(usage_to_date, workdays_days, weekend_days)

    @holiday_projected_usage_kwh = projected_totals[:kwh]
    @holiday_projected_usage_£ = projected_totals[:£]
    @holiday_projected_usage_co2 = projected_totals[:co2]

    # Ignore usage less than a threshold. A nil rating means the alert calculation
    # will be ignored by the application
    @rating = @holiday_usage_to_date_£ < USAGE_THRESHOLD_£ ? nil : 0.0
  end

  def calculate_usage_to_date(holiday_date_range)
    amr = aggregate_meter.amr_data
    start_date = [holiday_date_range.first, amr.start_date].max
    end_date   = [holiday_date_range.last,  amr.end_date, @today].min

    # lambda used to access data for a data typ
    lamda = ->(date, data_type) { amr.one_day_kwh(date, data_type) }
    # classified used to identify day type, into :workday, :weekend
    classifier = ->(date) { day_type(date) }

    # Calculate total, average for each day type for each data type (kwh, £ and co2)
    # Produces hash of data type => { weekend: {}, workday: {} }
    %i[kwh £ co2].map do |data_type|
      [
        data_type,
        @school.holidays.calculate_statistics(start_date, end_date, lamda, classifier: classifier, args: data_type, statistics: %i[total average])
      ]
    end.to_h
  end

  def holiday_name
    @holiday_period&.title
  end

  def holiday_type
    @holiday_period&.translation_type
  end

  def holiday_start_date
    @holiday_period&.start_date
  end

  def holiday_end_date
    @holiday_period&.end_date
  end

  def totals(usage_to_date)
    usage_to_date.transform_values { |v| v.values.map { |vv| vv[:total] }.sum }
  end

  def day_type(date)
    weekend?(date) ? :weekend : :workday
  end

  # Calculate number of days of each type in holiday period
  def holiday_weekday_workday_stats(holiday_date_range)
    weekend_days  = holiday_date_range.count { |d| weekend?(d) }
    workdays_days = holiday_date_range.last -  holiday_date_range.first + 1 - weekend_days
    [workdays_days, weekend_days]
  end

  # Using existing usage, project kwh, £, co2 usage for entire holiday
  def calculate_projected_totals(usage_to_date, workdays_days, weekend_days)
    usage_to_date.transform_values do |v|
      # at start of holiday may only have sample weekend or weekday,
      # so use backup type if missing sample i.e. workday if no weekend day sample etc.
      workdays_days * (v.dig(:workday, :average) || v.dig(:weekend, :average)) +
        weekend_days * (v.dig(:weekend, :average) || v.dig(:workday, :average))
    end
  end

  def summary
    return nil if @holiday_period.nil?

    if @today < @holiday_period.end_date
      I18n.t("#{i18n_prefix}.holiday_cost_to_date",
             holiday_name: holiday_name,
             date: I18n.l(@asof_date, format: '%A %e %b %Y'),
             cost_to_date: FormatEnergyUnit.format(:£, @holiday_usage_to_date_£)) +
        I18n.t("#{i18n_prefix}.holiday_predicted_cost",
               predicted_cost: FormatEnergyUnit.format(:£, @holiday_projected_usage_£))
    else
      I18n.t("#{i18n_prefix}.holiday_cost_to_date",
             holiday_name: holiday_name,
             date: I18n.l(@asof_date, format: '%A %e %b %Y'),
             usage_to_date: FormatEnergyUnit.format(:£, @holiday_usage_to_date_£))
    end
  end
end
