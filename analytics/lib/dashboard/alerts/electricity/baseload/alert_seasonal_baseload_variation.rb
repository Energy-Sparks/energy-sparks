#======================== Change in Electricity Baseload Analysis =============
require_relative '../alert_electricity_only_base.rb'

class AlertSeasonalBaseloadVariation < AlertBaseloadBase
  attr_reader :winter_kw, :summer_kw, :percent_seasonal_variation
  attr_reader :annual_cost_kwh, :annual_cost_£, :annual_cost_£current, :annual_cost_co2
  attr_reader :one_year_baseload_chart

  def initialize(school, report_type = :seasonalbaseload, meter = school.aggregated_electricity_meters)
    super(school, report_type, meter)
  end

  TEMPLATE_VARIABLES = {
    winter_kw: {
      description: 'winter baseload kw',
      units:  :kw,
      benchmark_code: 'wtbl'
    },
    summer_kw: {
      description: 'summer baseload kw',
      units:  :kw,
      benchmark_code: 'smbl'
    },
    percent_seasonal_variation: {
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
      description: 'annual cost of seasonal baseload variation (co2)',
      units:  :co2
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
    'Seasonal variation in baseload'
  end

  def commentary
    [ { type: :html,  content: evaluation_html } ]
  end

  def self.background_and_advice_on_reducing_issue
    [ { type: :html,  content: background_advice_html } ]
  end

  def evaluation_html
    text = %(
              <% if rating > 4 %>
                You are doing <%= adjective %>, there is limited variation between seasons.
                Your average usage in the winter is <%= format_kw(winter_kw) %> and
                <%= format_kw(summer_kw) %> in the summer.
              <% else %>
                There is a large variation in your seasonal usage from <%= format_kw(winter_kw) %>
                in the winter to <%= format_kw(summer_kw) %> in the summer. Reducing this difference
                could save you <%= FormatUnit.format(:£, @annual_cost_£current, :html) %> annually.
              <% end %>
            )
    ERB.new(text).result(binding)
  end

  private

  def calculate(asof_date)
    super(asof_date)
    # def 'enough_data' doesn;t know the asof_date
    raise EnergySparksNotEnoughDataException, "Needs 1 years amr data for as of date #{asof_date}" unless baseload_analysis.one_years_data?(asof_date)
    @winter_kw = baseload_analysis.winter_kw(asof_date)
    @summer_kw = baseload_analysis.summer_kw(asof_date)
    @percent_seasonal_variation = baseload_analysis.percent_seasonal_variation(asof_date)

    @annual_cost_kwh      = baseload_analysis.costs_of_baseload_above_minimum_kwh(asof_date, @summer_kw)
    @annual_cost_£        = @annual_cost_kwh * blended_baseload_rate_£_per_kwh
    @annual_cost_£current = @annual_cost_kwh * blended_baseload_rate_£current_per_kwh
    @annual_co2           = @annual_cost_kwh * blended_co2_per_kwh

    assign_commmon_saving_variables(
      one_year_saving_kwh: @annual_cost_kwh,
      one_year_saving_£: Range.new(@annual_cost_£current, @annual_cost_£ ),
      one_year_saving_co2: @annual_co2)

    @rating = calculate_rating_from_range(0, 0.50, @percent_seasonal_variation.magnitude)

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  def self.background_advice_html
    %(
      <h3>Assessment of seasonal variation in baseload:</h3>
      <p>
        Your out of hours baseload usage shouldn't really vary signifcantly between
        seasons; you shouldn't be consuming more electricity overnight in the
        winter than in the summer.
      </p>
      <p>
        If your school has signifcant variation in consumption between seasons you
        will need to do some detective work in your school to try to find out
        why and to remedy the situation. What is turned on overnight in the winter
        which is not turned on in the summer? Does it need to be turned on, and if so
        could a timer be fitted to ensure it is not on overnight and at weekends?
      </p>
    )
  end

  def adjective
    @adjective ||= calculate_adjective
  end

  def calculate_adjective
    if rating > 7
      'well'
    elsif rating > 4
      'ok'
    else
      'poorly'
    end
  end
end
