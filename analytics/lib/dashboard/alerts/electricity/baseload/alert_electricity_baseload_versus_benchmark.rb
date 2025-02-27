#======================== Electricity Baseload Analysis Versus Benchmark =====
require_relative '../../common/alert_analysis_base.rb'
require_relative '../../common/alert_floor_area_pupils_mixin.rb'

class AlertElectricityBaseloadVersusBenchmark < AlertBaseloadBase
  include AlertFloorAreaMixin
  PERCENT_TOO_HIGH_MARGIN = 1.10
  attr_reader :average_baseload_last_year_kw,  :average_baseload_last_year_kwh
  attr_reader :average_baseload_last_year_£, :average_baseload_last_year_£current

  attr_reader :benchmark_per_pupil_kw, :exemplar_per_pupil_kw

  attr_reader :one_year_benchmark_by_pupil_kwh, :one_year_benchmark_by_pupil_£
  attr_reader :one_year_saving_versus_benchmark_kwh, :one_year_saving_versus_benchmark_£, :one_year_saving_versus_benchmark_co2

  attr_reader :one_year_exemplar_by_pupil_kwh, :one_year_exemplar_by_pupil_£
  attr_reader :one_year_saving_versus_exemplar_kwh, :one_year_saving_versus_exemplar_£

  attr_reader :one_year_baseload_per_pupil_kw, :one_year_baseload_per_pupil_kwh, :one_year_baseload_per_pupil_£
  attr_reader :one_year_baseload_per_floor_area_kw, :one_year_baseload_per_floor_area_kwh, :one_year_baseload_per_floor_area_£
  attr_reader :average_baseload_last_year_co2, :one_year_benchmark_by_pupil_co2, :one_year_exemplar_by_pupil_co2
  attr_reader :one_year_saving_versus_exemplar_co2, :one_year_baseload_per_pupil_co2, :one_year_baseload_per_floor_area_co2
  attr_reader :cost_saving_through_1_kw_reduction_in_baseload_£

  def initialize(school, report_type = :baseloadbenchmark, meter = school.aggregated_electricity_meters)
    super(school, report_type, meter)
  end

  def self.template_variables
    specific = {'Annual electricity baseload usage versus benchmark' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    average_baseload_last_year_kw: {
      description: 'Average baseload last year kW',
      units:  { kw: :electricity},
      benchmark_code: 'lykw'
    },
    average_baseload_last_year_£: {
      description: 'Average baseload last year - value in £s (so kW * 24.0 * 365 * 15p or blended rate for differential tariff) (historic tariff)',
      units:  :£,
      benchmark_code: 'lygb'
    },
    average_baseload_last_year_£current: {
      description: 'Average baseload last year - value in £s (so kW * 24.0 * 365 * 15p or blended rate for differential tariff) (latest tariff)',
      units:  :£,
    },
    average_baseload_last_year_co2: {
      description: 'Average baseload last year - value in co2 (so kW * 24.0 * 365 * blended co2 rate for last year)',
      units:  :co2
    },
    average_baseload_last_year_kwh: {
      description: 'Average baseload last year - value in £s (so kW * 24.0 * 365)',
      units:  { kwh: :electricity}
    },
    benchmark_per_pupil_kw: {
      description: 'Benchmark baseload kW for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  { kw: :electricity}
    },
    exemplar_per_pupil_kw: {
      description: 'Exemplar baseload kW for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  { kw: :electricity}
    },

    one_year_benchmark_by_pupil_kwh: {
      description: 'Benchmark annual baseload kWh for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  { kwh: :electricity}
    },
    one_year_benchmark_by_pupil_£: {
      description: 'Benchmark annual baseload cost £ for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  :£
    },
    one_year_benchmark_by_pupil_co2: {
      description: 'Benchmark annual baseload cco2 emissions for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  :co2
    },
    one_year_saving_versus_benchmark_kwh: {
      description: 'Potential annual kWh saving if school matched benchmark - absolute value, so needs to be used in conjuction with adjective',
      units:  { kwh: :electricity}
    },
    one_year_saving_versus_benchmark_£: {
      description: 'Potential annual £ saving if school matched benchmark - absolute value, so needs to be used in conjuction with adjective',
      units:  :£
    },
    one_year_saving_versus_benchmark_co2: {
      description: 'Potential annual co2 saving if school matched benchmark - absolute value, so needs to be used in conjuction with adjective',
      units:  :co2
    },
    one_year_saving_versus_benchmark_adjective: {
      description: 'Adjective associated with whether saving is higher of lower than benchmark (higher or lower)',
      units:  String
    },
    cost_saving_through_1_kw_reduction_in_baseload_£: {
      description: 'cost saving through 1 kW reduction in baseload in next year',
      units:  :£_per_kw
    },
    one_year_exemplar_by_pupil_kwh: {
      description: 'Exemplar annual baseload kWh for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  { kwh: :electricity},
    },
    one_year_exemplar_by_pupil_£: {
      description: 'Exemplar annual baseload cost £ for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  :£,
    },
    one_year_exemplar_by_pupil_co2: {
      description: 'Exemplar annual baseload co2 emissions for a school of this number of pupils and type (secondaries have higher baseloads)',
      units:  :co2,
    },
    one_year_saving_versus_exemplar_kwh: {
      description: 'Potential annual kWh saving if school matched exemplar - absolute value, so needs to be used in conjunction with adjective',
      units:  { kwh: :electricity}
    },
    one_year_saving_versus_exemplar_£: {
      description: 'Potential annual £ saving if school matched exemplar - absolute value, so needs to be used in conjunction with adjective',
      units:  :£,
      benchmark_code: 'svex'
    },
    one_year_saving_versus_exemplar_co2: {
      description: 'Potential CO2 saving if school matched exemplar - absolute value, so needs to be used in conjunction with adjective',
      units:  :co2
    },
    one_year_saving_versus_exemplar_adjective: {
      description: 'Adjective associated with whether saving is higher of lower than exemplar (higher or lower)',
      units:  String
    },

    one_year_baseload_per_pupil_kw: {
      description: 'kW baseload for school per pupil - for energy expert use',
      units:  { kw: :electricity},
      benchmark_code: 'blpp'
    },
    one_year_baseload_per_pupil_kwh: {
      description: 'kwh baseload for school per pupil - for energy expert use',
      units:  { kwh: :electricity}
    },
    one_year_baseload_per_pupil_£: {
      description: '£ baseload for school per pupil - for energy expert use',
      units:  :£
    },
    one_year_baseload_per_pupil_co2: {
      description: 'co2 baseload for school per pupil - for energy expert use',
      units:  :co2
    },

    one_year_baseload_per_floor_area_kw: {
      description: 'kW baseload for school per floor area - for energy expert use',
      units:  { kw: :electricity}
    },
    one_year_baseload_per_floor_area_kwh: {
      description: 'kwh baseload for school per floor area - for energy expert use',
      units:  { kwh: :electricity}
    },
    one_year_baseload_per_floor_area_£: {
      description: '£ baseload for school per floor area - for energy expert use',
      units:  :£
    },
    one_year_baseload_per_floor_area_co2: {
      description: 'co2 baseload for school per floor area - for energy expert use',
      units:  :co2
    },

    one_year_baseload_chart: {
      description: 'chart of last years baseload',
      units: :chart
    },

    summary: {
      description: 'Description: annual benefit of moving to exemplar £',
      units: String
    }
  }.freeze

  def one_year_baseload_chart
    :alert_1_year_baseload
  end

  def commentary
    [ { type: :html,  content: evaluation_html } ]
  end

  def evaluation_html
    text = %(
              <% if average_baseload_last_year_kw < benchmark_per_pupil_kw %>
                You are doing well, your average annual baseload is
                <%= format_kw(average_baseload_last_year_kw) %> compared with a
                well managed school of a similar size's
                <%= format_kw(benchmark_per_pupil_kw) %> and
                an examplar schools's
                <%= FormatEnergyUnit.format(:kw, @exemplar_per_pupil_kw) %>,
                but there should still be opportunities to improve further.
              <% else %>
                Your average baseload last year was
                <%= format_kw(average_baseload_last_year_kw) %> compared with a
                well managed school of a similar size's
                <%= format_kw(benchmark_per_pupil_kw) %> and
                <%= FormatEnergyUnit.format(:kw, @exemplar_per_pupil_kw) %>
                at an exemplar school
                - there is significant room for improvement.
              <% end %>
            )
    ERB.new(text).result(binding)
  end

  def analysis_description
    'Comparison with other schools'
  end

  def enough_data
    is_aggregate_meter? && days_amr_data >= 1 ? :enough : :not_enough
  end

  private def calculate(asof_date)
    super(asof_date)
    @average_baseload_last_year_kw        = average_baseload_kw(asof_date)
    @average_baseload_last_year_£         = baseload_analysis.scaled_annual_baseload_cost_£(:£, asof_date)
    @average_baseload_last_year_£current  = baseload_analysis.scaled_annual_baseload_cost_£(:£current, asof_date)
    @average_baseload_last_year_kwh       = annual_average_baseload_kwh(asof_date)
    @average_baseload_last_year_co2       = annual_average_baseload_co2(asof_date)

    latest_electricity_tariff = blended_baseload_rate_£current_per_kwh

    @benchmark_per_pupil_kw = BenchmarkMetrics.recommended_baseload_for_pupils(pupils(asof_date - 365, asof_date), school_type)
    hours_in_year = 24.0 * 365.0

    @cost_saving_through_1_kw_reduction_in_baseload_£ = blended_baseload_rate_£current_per_kwh * hours_in_year

    @one_year_benchmark_by_pupil_kwh   = @benchmark_per_pupil_kw * hours_in_year
    @one_year_benchmark_by_pupil_£     = @one_year_benchmark_by_pupil_kwh * latest_electricity_tariff
    @one_year_benchmark_by_pupil_co2   = @one_year_benchmark_by_pupil_kwh * blended_co2_per_kwh

    @one_year_saving_versus_benchmark_kwh = @average_baseload_last_year_kwh - @one_year_benchmark_by_pupil_kwh
    @one_year_saving_versus_benchmark_£   = @one_year_saving_versus_benchmark_kwh * latest_electricity_tariff
    @one_year_saving_versus_benchmark_co2 = @one_year_saving_versus_benchmark_kwh * blended_co2_per_kwh

    @exemplar_per_pupil_kw = BenchmarkMetrics.exemplar_baseload_for_pupils(pupils(asof_date - 365, asof_date), school_type)

    @one_year_exemplar_by_pupil_kwh   = @exemplar_per_pupil_kw * hours_in_year
    @one_year_exemplar_by_pupil_£     = @one_year_exemplar_by_pupil_kwh * latest_electricity_tariff
    @one_year_exemplar_by_pupil_co2   = @one_year_exemplar_by_pupil_kwh * blended_co2_per_kwh

    @one_year_saving_versus_exemplar_kwh  = @average_baseload_last_year_kwh - @one_year_exemplar_by_pupil_kwh
    @one_year_saving_versus_exemplar_£    = @one_year_saving_versus_exemplar_kwh * latest_electricity_tariff
    @one_year_saving_versus_exemplar_co2  = @one_year_saving_versus_exemplar_kwh * blended_co2_per_kwh

    @one_year_baseload_per_pupil_kw        = @average_baseload_last_year_kw   / pupils(asof_date - 365, asof_date)
    @one_year_baseload_per_pupil_kwh       = @average_baseload_last_year_kwh  / pupils(asof_date - 365, asof_date)
    @one_year_baseload_per_pupil_£         = @average_baseload_last_year_£    / pupils(asof_date - 365, asof_date)
    @one_year_baseload_per_pupil_co2       = @average_baseload_last_year_co2  / pupils(asof_date - 365, asof_date)

    @one_year_baseload_per_floor_area_kw   = @average_baseload_last_year_kw   / floor_area(asof_date - 365, asof_date)
    @one_year_baseload_per_floor_area_kwh  = @average_baseload_last_year_kwh  / floor_area(asof_date - 365, asof_date)
    @one_year_baseload_per_floor_area_£    = @average_baseload_last_year_£    / floor_area(asof_date - 365, asof_date)
    @one_year_baseload_per_floor_area_co2  = @average_baseload_last_year_co2  / floor_area(asof_date - 365, asof_date)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @one_year_saving_versus_exemplar_kwh,
      one_year_saving_£: @one_year_saving_versus_exemplar_£,
      one_year_saving_co2: @one_year_saving_versus_exemplar_co2)

    # rating: benchmark value = 4.0, exemplar = 10.0
    percent_from_benchmark_to_exemplar = (@average_baseload_last_year_kwh - @one_year_benchmark_by_pupil_kwh) / (@one_year_exemplar_by_pupil_kwh - @one_year_benchmark_by_pupil_kwh)
    uncapped_rating = percent_from_benchmark_to_exemplar * (10.0 - 4.0) + 4.0
    @rating = [[uncapped_rating, 10.0].min, 0.0].max.round(2)

    @status = @rating < 6.0 ? :bad : :good

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  def one_year_saving_versus_benchmark_adjective
    Adjective.adjective_for(@one_year_saving_versus_benchmark_kwh, 0.0)
  end

  def one_year_saving_versus_exemplar_adjective
    Adjective.adjective_for(@one_year_saving_versus_exemplar_kwh, 0.0)
  end

  def summary
    if @one_year_saving_versus_exemplar_£ > 0
      I18n.t("#{i18n_prefix}.summary.high", saving: FormatEnergyUnit.format(:£, @one_year_saving_versus_exemplar_£, :text))
    else
      I18n.t("#{i18n_prefix}.summary.ok")
    end
  end

  private def dashboard_adjective
    @average_baseload_last_year_kw > @benchmark_per_pupil_kw * 1.05 ? 'too high' : 'good'
  end

  def dashboard_summary
    'Your electricity baseload is ' + dashboard_adjective
  end

  def dashboard_detail
    text = %{
      Your baseload over the last year of <%= FormatEnergyUnit.format(:kw, @average_baseload_last_year_kw) %> is <%= dashboard_adjective %>
      compared with average usage at other schools of <%= FormatEnergyUnit.format(:kw, @benchmark_per_pupil_kw) %> (pupil based),
      and <%= FormatEnergyUnit.format(:kw, @exemplar_per_pupil_kw) %> at an exemplar school.
    }
    ERB.new(text).result(binding)
  end

  def is_aggregate_meter?
    @school.aggregated_electricity_meters.mpxn == @meter.mpxn
  end
end
