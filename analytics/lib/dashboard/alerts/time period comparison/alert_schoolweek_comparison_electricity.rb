require_relative './alert_period_comparison_base.rb'
require "active_support/core_ext/integer/inflections"

class AlertSchoolWeekComparisonElectricity < AlertPeriodComparisonBase
  def initialize(school, type = :electricitypreviousschoolweekcomparison)
    super(school, type)
  end

  def self.template_variables
    specific = { 'Change in between last 2 school weeks' => dynamic_template_variables(:electricity) }
    specific2 = { 'School week formatted date variables' => formatted_date_variables }
    specific.merge!(specific2)
    specific.merge(superclass.template_variables)
  end

  def self.formatted_date_variables
    {
      current_period_start_short_date: { description: 'Current period start date',    units:  String },
      current_period_end_short_date:   { description: 'Current period end date',      units:  String },
      previous_period_start_short_date: { description: 'Previous period start date',  units:  String  },
      previous_period_end_short_date:   { description: 'Previous period end date',   units:  String  },
    }
  end

  def fuel_type; :electricity end

  def comparison_chart
    :last_2_school_weeks_electricity_comparison_alert
  end

  def calculate(asof_date)
    super(asof_date)
  end
  alias_method :analyse_private, :calculate

  def current_period_start_short_date
    format_date(@current_period_start_date)
  end

  def current_period_end_short_date
    format_date(@current_period_end_date)
  end

  def previous_period_start_short_date
    format_date(@previous_period_start_date)
  end

  def previous_period_end_short_date
    format_date(@previous_period_end_date)
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def reporting_period
    :last_2_weeks
  end

  protected def max_days_out_of_date_while_still_relevant
    21
  end

  private def period_type
    'school week'
  end

  private def format_date(date)
    #rely on .ordinalize here so we can hook in custom formatting for Welsh
    I18n.l(date, format: "#{date.day.ordinalize} %B")
  end

  protected def period_name(period)
    I18nHelper.holiday(period.type)
  end

  protected def current_period_name(current_period)
    I18n.t("analytics.common.last_school_week") + " (#{period_name(current_period)})"
  end

  protected def previous_period_name(previous_period)
    I18n.t("analytics.common.previous_school_week") + " (#{period_name(previous_period)})"
  end

  protected def period_name(period)
    I18n.t('analytics.from_and_to',
      from_date: I18n.l(period.start_date, format: '%a %d-%m-%Y'),
      to_date: I18n.l(period.end_date, format: '%a %d-%m-%Y'))
  end

  protected def last_two_periods(asof_date)
    [school_week(asof_date, 0), school_week(asof_date, -1)]
  end

  private def school_week(asof_date, offset)
    sunday, saturday, _week_count = @school.holidays.nth_school_week(asof_date, offset)
    SchoolDatePeriod.new(:alert, "School Week offset #{offset}", sunday, saturday)
  end

  private def fuel_time_of_year_priority(asof_date, current_period)
    5.0
  end
end
