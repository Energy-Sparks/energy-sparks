#======================== ASC Limit ===========================
require_relative '../alert_electricity_only_base.rb'

class AlertMeterASCLimit < AlertElectricityOnlyBase
  SAVING_PER_1_KW_ASC_LIMIT_REDUCTION_£_PER_YEAR = 1000.0 / 100.0
  ASC_MARGIN_PERCENT = 0.1
  attr_reader :maximum_kw_meter_period_kw, :asc_limit_kw

  def initialize(school)
    super(school, :asclimit)
    # should really use asof date but not available in constructor
    if @relevance == :relevant
      opportunities = all_agreed_supply_capacities_with_peak_kw(Date.today)
      @relevance = opportunities.empty? ? :never_relevant : :relevant
    end
  end

  def self.template_variables
    specific = {'ASC Supply Limit' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    :enough
  end

  def maximum_alert_date
    Date.today
  end

  TEMPLATE_VARIABLES = {
    maximum_kw_meter_period_kw: {
      description: 'Peak kW usage over period for which meter data available (potentially aggregate of multiple meters)',
      units:  :kw
    },
    asc_limit_kw: {
      description: 'Agreed Supply Capacity (ASC) limit total (potentially aggregate of multiple metersmultiple meters)',
      units:  :kw
    },
    text_explaining_asc_meters_below_limit: {
      description: 'Text explaining ASC meters within limit (potentially multiple meters)',
      units:  String
    },
    peak_kw_chart: {
      description: 'Chart showing daily peak kW over time, critical to observe maximum kW value, compared with ASC limit',
      units: :chart
    }
  }

  protected def format(unit, value, format, in_table, level)
    FormatUnit.format(unit, value, format, true, in_table, unit == :£ ? :no_decimals : level)
  end

  def peak_kw_chart
    :peak_kw
  end

  def cost_of_consolidating_1_meter_£
    COST_OF_1_METER_CONSOLIDATION_£
  end

  protected def number_of_live_meters
    live_meters.length
  end

  protected def live_meters
    max_combined_date = aggregate_meter.amr_data.end_date
    @live_meters ||= @school.electricity_meters.select { |meter| meter.amr_data.end_date >= max_combined_date }
  end

  private def calculate(asof_date)
    @opportunities = all_agreed_supply_capacities_with_peak_kw(asof_date)
    unless @opportunities.empty?
      @asc_limit_kw = aggregate_asc_limit_kw(@opportunities)
      @maximum_kw_meter_period_kw = aggregate_peak_kw(@opportunities)
      annual_saving_£ = aggregate_annual_saving_£(@opportunities)

      assign_commmon_saving_variables(one_year_saving_£: annual_saving_£, one_year_saving_co2: 0.0)
      @rating = calculate_rating_from_range(400.0, 3000.0, annual_saving_£)
    else
      @rating = 10.0
    end
  end
  alias_method :analyse_private, :calculate

  private def potential_annual_saving_£(peak_kw, asc_limit_kw)
    peak_plus_margin_kw = peak_kw * (1.0 + ASC_MARGIN_PERCENT)
    (asc_limit_kw - peak_kw) * SAVING_PER_1_KW_ASC_LIMIT_REDUCTION_£_PER_YEAR
  end

  private def close_to_margin(peak_kw, asc_limit_kw)
    peak_kw * (1.0 + ASC_MARGIN_PERCENT) > asc_limit_kw
  end

  private def agreed_supply_capacity(meter, date)
    asc = meter.meter_tariffs.accounting_tariff_for_date(date)&.tariff
    asc.nil? ? nil : asc[:asc_limit_kw]
  end

  def text_explaining_asc_meters_below_limit
    text_for_all_meters(@opportunities)
  end

  private def text_for_all_meters(opportunity_list)
    text = ''
    opportunity_list.each do |mpan, asc_info|
      text += (text_for_one_meter(mpan, asc_info) + " ")
    end
    text
  end

  private def text_for_one_meter(mpan, asc_info)
    I18n.t("#{i18n_prefix}.peak_power_consumption",
      mpan: mpan,
      asc_limit: FormatUnit.format(:kw, asc_info[:asc_limit_kw]),
      peak_kw: FormatUnit.format(:kw, asc_info[:peak_kw])) + " " +
      text_for_opportunity_or_risk(asc_info)
  end

  private def text_for_opportunity_or_risk(asc_info)
    if asc_info[:close_to_margin]
      I18n.t("#{i18n_prefix}.close_to_margin")
    else
      I18n.t("#{i18n_prefix}.opportunity",
        annual_saving: FormatUnit.format(:£, asc_info[:annual_saving_£]),
        ten_year_saving: FormatUnit.format(:£, asc_info[:annual_saving_£] * 10.0))
    end
  end

  private def all_agreed_supply_capacities_with_peak_kw(date)
    mpan_to_asc = {}
    live_meters.each do |meter|
      mpan_to_asc[meter.mpan_mprn] = agreed_supply_capacity(meter, date)
    end
    meters_with_asc_limits = mpan_to_asc.compact

    meters_with_limits_and_peak_values = {}
    meters_with_asc_limits.each do |mpan, asc_limit_kw|
      peak_kw = @school.meter?(mpan).amr_data.peak_kw_date_range_with_dates.values[0]
      meters_with_limits_and_peak_values[mpan] = {
        asc_limit_kw:     asc_limit_kw,
        peak_kw:          peak_kw,
        annual_saving_£:  potential_annual_saving_£(peak_kw, asc_limit_kw),
        close_to_margin:  close_to_margin(peak_kw, asc_limit_kw)
      }
    end
    meters_with_limits_and_peak_values
  end

  private def aggregate_asc_limit_kw(meters_with_limits_and_peak_values)
    meters_with_limits_and_peak_values.values.map { |info| info[:asc_limit_kw] }.sum
  end

  private def aggregate_peak_kw(meters_with_limits_and_peak_values)
    meters_with_limits_and_peak_values.values.map { |info| info[:peak_kw] }.sum
  end

  private def aggregate_annual_saving_£(meters_with_limits_and_peak_values)
    meters_with_limits_and_peak_values.values.map { |info| info[:annual_saving_£] }.sum
  end
end
