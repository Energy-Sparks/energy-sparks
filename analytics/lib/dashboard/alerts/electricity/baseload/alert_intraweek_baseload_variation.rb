#======================== Change in Electricity Baseload Analysis =============
require_relative '../alert_electricity_only_base.rb'

class AlertIntraweekBaseloadVariation < AlertBaseloadBase
  attr_reader :max_day_kw, :min_day_kw, :percent_intraday_variation, :max_day, :min_day
  attr_reader :annual_cost_kwh, :annual_cost_£,  :annual_cost_£current, :annual_co2

  def initialize(school, report_type = :intraweekbaseload, meter = school.aggregated_electricity_meters)
    super(school, report_type, meter)
  end

  TEMPLATE_VARIABLES = {
    max_day_kw: {
      description: 'max average day baseload kw',
      units:  :kw,
      benchmark_code: 'mxbk'
    },
    max_day_str: {
      description: 'Day of the week name with max average baseload',
      units:  String,
      benchmark_code: 'mxbd'
    },
    max_day: {
      description: 'Day of the week number with max average baseload',
      units:  Integer,
    },
    min_day_kw: {
      description: 'min average day baseload kw',
      units:  :kw,
      benchmark_code: 'mnbk'
    },
    min_day_str: {
      description: 'Day of the week name with min average baseload',
      units:  String,
      benchmark_code: 'mnbd'
    },
    min_day: {
      description: 'Day of the week number with min average baseload',
      units:  Integer
    },
    percent_intraday_variation: {
      description: 'seasonal baseload variation percent (relative)',
      units:  :relative_percent,
      benchmark_code: 'sblp'
    },
    annual_cost_kwh: {
      description: 'annual cost of seasonal baseload variation (kWh)',
      units:  :kwh,
      benchmark_code: 'ckwh'
    },
    annual_cost_£: {
      description: 'annual cost of seasonal baseload variation (£) at historic tariff',
      units:  :£,
      benchmark_code: 'cgbp'
    },
    annual_cost_£current: {
      description: 'annual cost of seasonal baseload variation (£) as latest tariff',
      units:  :£,
      benchmark_code: 'c€bp'
    },
    annual_co2: {
      description: 'annual cost of seasonal baseload variation (CO2)',
      units:  :co2
    },
    adjective: {
      description: 'how well the school is doing versus the rating: well, ok, poorly',
      units:  String
    },
    one_year_baseload_chart: {
      description: 'chart of last years baseload',
      units: :chart
    }
  }.freeze

  def one_year_baseload_chart
    :alert_1_year_baseload
  end

  def self.template_variables
    specific = {'Change In Baseload Short Term' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  def enough_data
    baseload_analysis.one_years_data? ? :enough : :not_enough
  end

  def analysis_description
    'Variation in baseload between days of week'
  end

  def commentary
    charts_and_html = []
    charts_and_html.push( { type: :html,  content: evaluation_html } )
    AdviceBase.meter_specific_chart_config(:electricity_baseload_by_day_of_week, @meter.mpxn)
    # charts_and_html.push( { type: :chart_name, content: :electricity_baseload_by_day_of_week } ) if rating < 4
    charts_and_html
  end

  def self.background_and_advice_on_reducing_issue
    [ { type: :html,  content: background_advice_html } ]
  end

  def evaluation_html
    text = %(
              <% if rating > 4 %>
                You are doing <%= adjective %>, there is limited variation between weekday and weekend usage.
                You highest average daily usage occurs on <%= max_day_str %> of <%= format_kw(max_day_kw) %>,
                and your lowest on <%= min_day_str %> of <%= format_kw(min_day_kw) %>.
              <% else %>
                Your usage between days of the week is inconsistent and could be improved,
                doing this would save <%= FormatEnergyUnit.format(:£, @average_one_year_saving_£, :html) %>.
                On <%= max_day_str %> your average baseload was <%= format_kw(max_day_kw) %>
                but on <%= min_day_str %> it was <%= format_kw(min_day_kw) %>.
                The chart below shows the average baseload over the last year by day of the week.
              <% end %>
            )
    ERB.new(text).result(binding)
  end

  private

  def calculate(asof_date)
    super(asof_date)
    # def 'enough_data' doesn;t know the asof_date
    raise EnergySparksNotEnoughDataException, "Needs 1 years amr data for as of date #{asof_date}" unless baseload_analysis.one_years_data?(asof_date)

    days_kw = baseload_analysis.average_intraweek_schoolday_kw(asof_date)

    @min_day_kw = days_kw.values.min
    @min_day = days_kw.key(@min_day_kw)

    @max_day_kw = days_kw.values.max
    @max_day = days_kw.key(@max_day_kw)

    @percent_intraday_variation = (@max_day_kw - @min_day_kw) / @min_day_kw

    week_saving_kwh = days_kw.values.map do |day_kw|
      (day_kw - @min_day_kw) * 24.0
    end.sum

    @annual_cost_kwh      = week_saving_kwh * 52.0 # ignore holiday calc
    @annual_cost_£        = @annual_cost_kwh * blended_baseload_rate_£_per_kwh
    @annual_cost_£current = @annual_cost_kwh * blended_baseload_rate_£current_per_kwh
    @annual_co2           = @annual_cost_kwh * blended_co2_per_kwh

    assign_commmon_saving_variables(
      one_year_saving_kwh: @annual_cost_kwh,
      one_year_saving_£: Range.new(@annual_cost_£current, @annual_cost_£),
      one_year_saving_co2: @annual_co2)

    @rating = calculate_rating_from_range(0.1, 0.3, @percent_intraday_variation.magnitude)

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  def self.background_advice_html
    %(
      <h3>Assessment of variation in baseload between days of the week:</h3>
      <p>
        One measure of how well your baseload is managed is to look at how much
        baseload varies between days. If your electrical baseload
        is similar on all days of the week then you are managing this aspect
        of you baseload well, in that generally your electricity consumption
        shouldn't be any different for example on a Saturday night night than for a
        Wednesday night.
      </p>
      <p>
        If there is a significant variation then you should consider why? Is something
        being left on during the week overnight which could be switched off everynight
        to save costs?
      </p>
    )
  end

  def min_day_str
    I18nHelper.day_name(@min_day)
  end

  def max_day_str
    I18nHelper.day_name(@max_day)
  end

  def adjective
    calculate_adjective
  end

  def calculate_adjective
    if rating > 7
      I18nHelper.adjective('well')
    elsif rating > 4
      I18nHelper.adjective('ok')
    else
      I18nHelper.adjective('poorly')
    end
  end
end
