require_relative '../../../../../app/services/baseload/baseload_analysis.rb'

class AlertBaseloadBase < AlertElectricityOnlyBase
  attr_reader :blended_baseload_rate_£_per_kwh, :blended_baseload_rate_£current_per_kwh, :has_changed_during_period_text
  attr_reader :annual_baseload_percent

  def initialize(school, report_type, meter = school.aggregated_electricity_meters)
    super(school, report_type)
    @report_type = report_type
    @meter = meter
  end

  def self.baseload_alerts
    [
      AlertElectricityBaseloadVersusBenchmark,
      AlertChangeInElectricityBaseloadShortTerm,
      AlertSeasonalBaseloadVariation,
      AlertIntraweekBaseloadVariation
    ]
  end

  TEMPLATE_VARIABLES = {
    blended_baseload_rate_£_per_kwh: {
      description: 'blended historic baseload tariff - £ per kWh',
      units:  :£_per_kwh
    },
    blended_baseload_rate_£current_per_kwh: {
      description: 'blended baseload tariff using latest tariff - £ per kWh',
      units:  :£_per_kwh,
      benchmark_code: '€prk'
    },
    annual_baseload_percent: {
      description: 'baseload as a percent of annual consumption',
      units:  :percent,
      benchmark_code: 'abkp'
    },
    has_changed_during_period_text: {
      description: 'the tariff has changed during the last year text, blank if not',
      units:  String
    }
  }.freeze

  def self.template_variables
    specific = {'Common baseload variables' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def calculate(asof_date)
    @blended_baseload_rate_£_per_kwh        = baseload_analysis.blended_baseload_tariff_rate_£_per_kwh(:£, asof_date)
    @blended_baseload_rate_£current_per_kwh = baseload_analysis.blended_baseload_tariff_rate_£_per_kwh(:£current, asof_date)
    @annual_baseload_percent = calculate_annual_baseload_percent(asof_date)

    start_date, end_date, _scale_to_year = baseload_analysis.scaled_annual_dates(asof_date)
    changed = aggregate_meter.meter_tariffs.meter_tariffs_differ_within_date_range?(start_date, end_date)
    @has_changed_during_period_text = changed ? I18n.t("analytics.tariff_change.change_within_period_caveat") : ''
  end

  def calculate_all_baseload_alerts(asof_date)
    self.class.baseload_alerts.map do |alert_class|
      alert = alert_class.new(@school, @report_type, @meter)
      [
        alert,
        valid_calculation(alert, asof_date)
      ]
    end.to_h
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def commentary
    [ { type: :html,  content: 'No advice yet' } ]
  end

  def self.background_and_advice_on_reducing_issue
    []
  end

  private

  def average_baseload(date1, date2)
    baseload_analysis.average_baseload_kw(date1, date2)
  end

  def average_baseload_kw(asof_date)
    baseload_analysis.average_annual_baseload_kw(asof_date)
  end

  def annual_average_baseload_kwh(asof_date)
    baseload_analysis.annual_average_baseload_kwh(asof_date)
  end

  def calculate_annual_baseload_percent(asof_date)
    @calculate_annual_baseload_percent ||= baseload_analysis.baseload_percent_annual_consumption(asof_date)
  end

  def annual_average_baseload_co2(asof_date)
    kwh = annual_average_baseload_kwh(asof_date)
    kwh * blended_co2_per_kwh
  end

  def scaled_annual_baseload_cost_£(datatype, asof_date)
    baseload_analysis.scaled_annual_baseload_cost_£(datatype, asof_date)
  end

  def baseload_analysis
    @baseload_analysis ||= Baseload::BaseloadAnalysis.new(@meter)
  end

  def valid_calculation(alert, asof_date)
    return false unless alert.valid_alert?
    alert.analyse(asof_date, true)
    alert.make_available_to_users?
  end

  def format_kw(value)
    FormatUnit.format(:kw, value, :html)
  end
end
