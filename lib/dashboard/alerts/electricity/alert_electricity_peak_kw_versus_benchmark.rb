require_relative '../common/alert_floor_area_pupils_mixin.rb'
class AlertElectricityPeakKWVersusBenchmark < AlertElectricityOnlyBase
  include AlertFloorAreaMixin
  attr_reader :average_school_day_last_year_kw, :average_school_day_last_year_kw_per_pupil
  attr_reader :average_school_day_last_year_kw_per_floor_area, :exemplar_kw
  attr_reader :one_year_saving_versus_exemplar_£, :one_year_saving_versus_exemplar_kwh, :one_year_saving_versus_exemplar_co2

  def initialize(school)
    super(school, :peakelectricbenchmark)
  end

  def self.template_variables
    specific = {'Average peak kW electricity usage versus benchmark' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    average_school_day_last_year_kw: {
      description: 'Average peak kW last year',
      units:  { kw: :electricity},
      benchmark_code: 'kwsc'
    },
    average_school_day_last_year_kw_per_pupil: {
      description: 'Average peak kW last year per pupil',
      units:  { kw: :electricity},
      benchmark_code: 'kwpp'
    },
    average_school_day_last_year_kw_per_floor_area: {
      description: 'Average peak kWh last year per floor area',
      units:  { kw: :electricity},
      benchmark_code: 'kwfa'
    },
    exemplar_kw: {
      description: 'Exemplar peak kW for school of same floor area',
      units:  { kw: :electricity},
      benchmark_code: 'kwex'
    },
    one_year_saving_versus_exemplar_kwh: {
      description: 'One year savings kWh versus exemplar for school of same floor area',
      units:  { kwh: :electricity}
    },
    one_year_saving_versus_exemplar_£: {
      description: 'One year savings £ versus exemplar for school of same floor area',
      units:  :£,
      benchmark_code: 'tex£'
    },
    one_year_saving_versus_exemplar_co2: {
      description: 'One year savings co2 versus exemplar for school of same floor area',
      units:  :co2
    },
    electricity_intraday_comparison_chart_6_months_apart: {
      description: 'Compares intraday usage 6 months apart',
      units: :chart
    }
  }

  def electricity_intraday_comparison_chart_6_months_apart
    :intraday_line_school_days_6months
  end

  def enough_data
    # scales result to 1 year
    days_amr_data >= 60 ? :enough : :not_enough
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  private def calculate(asof_date)
    pupil_count = pupils(asof_date - 365, asof_date)

    @average_school_day_last_year_kw = average_schoolday_peak_kw(asof_date)
    @average_school_day_last_year_kw_per_pupil = @average_school_day_last_year_kw / pupil_count
    @average_school_day_last_year_kw_per_floor_area = @average_school_day_last_year_kw / floor_area(asof_date - 365, asof_date)

    benchmark_kw = BenchmarkMetrics.benchmark_peak_kw(pupil_count, school_type)
    @exemplar_kw = BenchmarkMetrics.exemplar_peak_kw(pupil_count, school_type)

    potential_saving = consumption_above_exemplar_peak(asof_date, @exemplar_kw)

    @one_year_saving_versus_exemplar_kwh  = potential_saving[:kwh]
    @one_year_saving_versus_exemplar_£    = potential_saving[:£]
    @one_year_saving_versus_exemplar_co2  = potential_saving[:co2]

    # rating: benchmark value = 4.0, exemplar = 10.0
    percent_from_benchmark_to_exemplar = (@average_school_day_last_year_kw - benchmark_kw) / (@exemplar_kw - benchmark_kw)
    uncapped_rating = percent_from_benchmark_to_exemplar * (10.0 - 4.0) + 4.0
    @rating = [[uncapped_rating, 10.0].min, 0.0].max.round(2)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @one_year_saving_versus_exemplar_kwh,
      one_year_saving_£: @one_year_saving_versus_exemplar_£,
      one_year_saving_co2: @one_year_saving_versus_exemplar_co2)

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  private

  def full_date_range(asof_date)
    start_date = [asof_date - 364, aggregate_meter.amr_data.start_date].max
    start_date..asof_date
  end

  def scale_to_year(asof_date, val)
    scale_factor = 365.0 / (full_date_range(asof_date).last - full_date_range(asof_date).first + 1)
    val * scale_factor
  end

  def consumption_above_exemplar_peak(asof_date, exemplar_kw)
    exemplar_kwh = exemplar_kw / 2.0

    totals = { kwh: 0.0, £: 0.0, co2: 0.0 }

    full_date_range(asof_date).each do |date|
      (0..47).each do |hhi|
        kwh = aggregate_meter.amr_data.kwh(date, hhi, :kwh)
        percent_above_exemplar = capped_percent(kwh, exemplar_kwh)

        unless percent_above_exemplar.nil?
          totals[:kwh]  += percent_above_exemplar * kwh
          totals[:£]    += percent_above_exemplar * aggregate_meter.amr_data.kwh(date, hhi, :£current)
          totals[:co2]  += percent_above_exemplar * aggregate_meter.amr_data.kwh(date, hhi, :co2)
        end
      end
    end

    totals.transform_values { |v| scale_to_year(asof_date, v) }
  end

  def capped_percent(kwh, exemplar_kwh)
    return nil if kwh <= exemplar_kwh
    (kwh - exemplar_kwh) / kwh
  end

  def average_schoolday_peak_kw(asof_date)
    peak_kws = []
    full_date_range(asof_date).each do |date|
      peak_kws.push(aggregate_meter.amr_data.statistical_peak_kw(date)) if occupied?(date)
    end
    peak_kws.sum / peak_kws.length
  end
end
