#======================== Change in Electricity Baseload Analysis =============
require_relative '../alert_electricity_only_base.rb'

class AlertChangeInElectricityBaseloadShortTerm < AlertBaseloadBase

  MAXBASELOADCHANGE = 1.15

  attr_reader :average_baseload_last_year_kw, :average_baseload_last_week_kw
  attr_reader :change_in_baseload_kw, :kw_value_at_10_percent_saving
  attr_reader :last_year_baseload_kwh, :last_week_baseload_kwh
  attr_reader :last_week_change_in_baseload_kwh, :next_year_change_in_baseload_kwh
  attr_reader :last_year_baseload_£, :last_year_baseload_£current
  attr_reader :last_week_baseload_£, :last_week_baseload_£current, :next_year_change_in_baseload_£
  attr_reader :saving_in_annual_costs_through_10_percent_baseload_reduction
  attr_reader :predicted_percent_increase_in_usage, :significant_increase_in_baseload
  attr_reader :one_year_baseload_chart
  attr_reader :predicted_percent_increase_in_usage_absolute, :next_year_change_in_baseload_absolute_£
  attr_reader :last_year_baseload_co2, :last_week_baseload_co2, :next_year_change_in_baseload_co2, :next_year_change_in_baseload_absolute_co2
  attr_reader :cost_saving_through_1_kw_reduction_in_baseload_£
  attr_reader :next_year_change_in_baseload_£current
  attr_reader :up_until_date, :from_date

  def initialize(school, report_type = :baseloadchangeshortterm, meter = school.aggregated_electricity_meters)
    super(school, report_type, meter)
  end

  protected def max_days_out_of_date_while_still_relevant
    21
  end

  TEMPLATE_VARIABLES = {
    average_baseload_last_year_kw: {
      description: 'average baseload over last year',
      units:  :kw,
      benchmark_code: 'blly'
    },
    average_baseload_last_week_kw: {
      description: 'average baseload over last week',
      units:  :kw,
      benchmark_code: 'bllw'
    },
    change_in_baseload_kw: {
      description: 'change in baseload last week compared with the average over the last year',
      units:  :kw,
      benchmark_code: 'blch'
    },
    last_year_baseload_kwh: {
      description: 'baseload last year (kwh)',
      units:  {kwh: :electricity}
    },
    last_week_baseload_kwh: {
      description: 'baseload last week (kwh)',
      units:  {kwh: :electricity}
    },
    cost_saving_through_1_kw_reduction_in_baseload_£: {
      description: 'cost saving through 1 kW reduction in baseload in next year',
      units:  :£_per_kw
    },
    last_week_change_in_baseload_kwh: {
      description: 'change in baseload between last week and average of last year (kwh)',
      units:  {kwh: :electricity}
    },
    next_year_change_in_baseload_kwh: {
      description: 'predicted impact of change in baseload over next year (kwh)',
      units:  {kwh: :electricity}
    },
    last_year_baseload_£: {
      description: 'cost of the baseload electricity consumption last year (historic tariffs)',
      units:  :£
    },
    last_year_baseload_£current: {
      description: 'cost of the baseload electricity consumption last year (latest tariffs)',
      units:  :£current
    },
    last_week_baseload_£: {
      description: 'cost of the baseload electricity consumption last week (historic tariffs)',
      units:  :£
    },
    last_week_baseload_£current: {
      description: 'cost of the baseload electricity consumption last week (latest tariffs)',
      units:  :£current
    },
    next_year_change_in_baseload_£current: {
      description: 'projected addition cost of change in baseload next year (current tariffs)',
      units:  :£current,
      benchmark_code: 'anc€'
    },
    next_year_change_in_baseload_absolute_£: {
      description: 'projected addition cost of change in baseload next year - in absolute terms i.e. always positive',
      units:  :£
    },
    last_year_baseload_co2: {
      description: 'co2 emissions from baseload electricity consumption last year',
      units:  :co2
    },
    last_week_baseload_co2: {
      description: 'co2 emissions from baseload electricity consumption last week',
      units:  :co2
    },
    next_year_change_in_baseload_co2: {
      description: 'projected addition co2 emissions from change in baseload next year',
      units:  :co2
    },
    next_year_change_in_baseload_absolute_co2: {
      description: 'projected co2 emissions from in baseload next year - in absolute terms i.e. always positive',
      units:  :co2
    },
    predicted_percent_increase_in_usage: {
      description: 'percentage increase in baseload',
      units:  :percent,
      benchmark_code: 'bspc'
    },
    predicted_percent_increase_in_usage_absolute: {
      description: 'percentage increase in baseload = always positive',
      units:  :percent,
    },
    significant_increase_in_baseload: {
      description: 'significant increase in baseload flag',
      units:  TrueClass
    },
    saving_in_annual_costs_through_10_percent_baseload_reduction:  {
      description: 'cost saving if baseload reduced by 10%',
      units:  :£
    },
    kw_value_at_10_percent_saving:  {
      description: 'kw at 10 percent reduction on last years average baseload',
      units:  :kw
    },
    from_date: {
      description: 'first meter reading date used for analysis - 1 week before up_until_date',
      units: :date
    },
    up_until_date: {
      description: 'last meter reading date used for analysis',
      units: :date
    },
    one_year_baseload_chart: {
      description: 'chart of last years baseload',
      units: :chart
    }

  }.freeze

  def one_year_baseload_chart
    :alert_1_year_baseload
  end

  def enough_data
    days_amr_data > 6 * 7 ? :enough : (days_amr_data > 3 * 7 ? :minimum_might_not_be_accurate : :not_enough)
  end

  def analysis_description
    I18n.t("#{i18n_prefix}.analysis_description")
  end

  def commentary
    [ { type: :html,  content: evaluation_html } ]
  end

  def evaluation_html
    text = %(
              <% if change_in_baseload_kw < 0 %>
                You have been doing well recently, your baseload last week was <%= format_kw(average_baseload_last_week_kw) %>
                compared with <%= format_kw(average_baseload_last_year_kw) %> on average over the last year.
              <% else %>
              Your baseload has increased, last week it was <%= format_kw(average_baseload_last_week_kw) %>
              compared with <%= format_kw(average_baseload_last_year_kw) %> on average over the last year.
              <% end %>
            )
    ERB.new(text).result(binding)
  end

  def self.template_variables
    specific = {'Change In Baseload Short Term' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def calculate(asof_date)
    super(asof_date)
    @up_until_date = asof_date

    @average_baseload_last_year_kw = average_baseload_kw(asof_date)
    @kw_value_at_10_percent_saving = @average_baseload_last_year_kw * 0.9

    @from_date = baseload_analysis.one_week_ago(asof_date)
    @average_baseload_last_week_kw = baseload_analysis.average_baseload_last_week_kw(asof_date)

    @change_in_baseload_kw = @average_baseload_last_week_kw - @average_baseload_last_year_kw
    @predicted_percent_increase_in_usage = (@average_baseload_last_week_kw - @average_baseload_last_year_kw) / @average_baseload_last_year_kw
    @predicted_percent_increase_in_usage_absolute = @predicted_percent_increase_in_usage.magnitude

    hours_in_year = 365.0 * 24.0
    hours_in_week =   7.0 * 24.0

    @last_year_baseload_kwh           = annual_average_baseload_kwh(asof_date)
    @last_week_baseload_kwh           = @average_baseload_last_week_kw * hours_in_week
    @last_week_change_in_baseload_kwh = @change_in_baseload_kw * hours_in_week
    @next_year_change_in_baseload_kwh = @change_in_baseload_kw * hours_in_year

    @last_year_baseload_£                    = scaled_annual_baseload_cost_£(:£, asof_date)
    @last_year_baseload_£current             = scaled_annual_baseload_cost_£(:£current, asof_date)
    @last_week_baseload_£                    = baseload_analysis.baseload_economic_cost_date_range_£(asof_date - 7, asof_date, :£)
    @last_week_baseload_£current             = baseload_analysis.baseload_economic_cost_date_range_£(asof_date - 7, asof_date, :£current)
    @next_year_change_in_baseload_£current   = @next_year_change_in_baseload_kwh * blended_baseload_rate_£current_per_kwh
    @cost_saving_through_1_kw_reduction_in_baseload_£ = @next_year_change_in_baseload_£current / @change_in_baseload_kw
    @next_year_change_in_baseload_absolute_£ = @next_year_change_in_baseload_£current.magnitude

    @last_year_baseload_co2                     = annual_average_baseload_co2(asof_date)
    @last_week_baseload_co2                     = blended_co2_per_kwh * @last_week_baseload_kwh
    @next_year_change_in_baseload_co2           = blended_co2_per_kwh * @next_year_change_in_baseload_kwh
    @next_year_change_in_baseload_absolute_co2  = @next_year_change_in_baseload_co2.magnitude

    @saving_in_annual_costs_through_10_percent_baseload_reduction = @last_year_baseload_£current * 0.1

    assign_commmon_saving_variables(
      one_year_saving_kwh: @next_year_change_in_baseload_kwh,
      one_year_saving_£: @next_year_change_in_baseload_£current,
      one_year_saving_co2: @next_year_change_in_baseload_co2)

    @rating = calculate_rating_from_range(-0.05, 0.15, @predicted_percent_increase_in_usage)

    @significant_increase_in_baseload = @rating.to_f < 7.0

    @status = @significant_increase_in_baseload ? :bad : :good

    @term = :shortterm
  end
  alias_method :analyse_private, :calculate
end
