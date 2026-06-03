#==============================================================================
#==============================================================================
#========================HEATING/GAS===========================================
#==============================================================================
#==============================================================================
#==============================================================================
#======================== Gas Annual kWh Versus Benchmark =====================
# currently not derived from a common base class with electricity as we may need
# to tmperature adjust in future
# storage heaters derived from this class, most of code shared - beware
require_relative '../gas/alert_gas_only_base.rb'
require_relative '../common/alert_floor_area_pupils_mixin.rb'

class AlertGasAnnualVersusBenchmark < AlertGasModelBase
  DAYSINYEAR = 363 # 364 days inclusive - consistent with charts which are 7 days * 52 weeks
  include AlertFloorAreaMixin
  attr_reader :last_year_kwh, :previous_year_kwh, :last_year_£, :previous_year_£, :last_year_co2
  attr_reader :last_year_£current, :previous_year_£current

  attr_reader :one_year_benchmark_floor_area_kwh, :one_year_benchmark_floor_area_£
  attr_reader :one_year_saving_versus_benchmark_kwh, :one_year_saving_versus_benchmark_£

  attr_reader :one_year_exemplar_floor_area_kwh, :one_year_exemplar_floor_area_£
  attr_reader :one_year_saving_versus_exemplar_kwh, :one_year_saving_versus_exemplar_£
  attr_reader :one_year_saving_versus_exemplar_co2, :one_year_exemplar_floor_area_co2

  attr_reader :one_year_gas_per_pupil_kwh, :one_year_gas_per_pupil_£
  attr_reader :one_year_gas_per_floor_area_kwh, :one_year_gas_per_floor_area_£
  attr_reader :one_year_gas_per_pupil_co2, :one_year_gas_per_floor_area_co2

  attr_reader :degree_day_adjustment
  attr_reader :last_year_degree_days, :previous_year_degree_days, :degree_days_annual_change
  attr_reader :temperature_adjusted_previous_year_kwh, :temperature_adjusted_percent

  attr_reader :one_year_gas_per_pupil_normalised_kwh, :one_year_gas_per_pupil_normalised_£
  attr_reader :one_year_gas_per_floor_area_normalised_kwh, :one_year_gas_per_floor_area_normalised_£

  attr_reader :per_floor_area_gas_benchmark_£
  attr_reader :percent_difference_from_average_per_floor_area
  attr_reader :percent_difference_from_exemplar_per_floor_area
  attr_reader :tariff_has_changed_during_period_text

  attr_reader :historic_rate_£_per_kwh, :current_rate_£_per_kwh

  attr_reader :one_year_benchmark_floor_area_£current,  :one_year_saving_versus_benchmark_£current
  attr_reader :one_year_exemplar_floor_area_£current,   :one_year_saving_versus_exemplar_£current
  attr_reader :one_year_gas_per_pupil_£current, :one_year_gas_per_floor_area_£current
  attr_reader :one_year_gas_per_pupil_normalised_£current, :one_year_gas_per_floor_area_normalised_£current

  def initialize(school, type = :annualgasbenchmark)
    super(school, type)
  end

  def self.template_variables
    specific = {'Annual gas usage versus benchmark' => gas_benchmark_template_variables}
    specific.merge(self.superclass.template_variables)
  end

  def self.gas_benchmark_template_variables
    {
      last_year_kwh: {
        description:    "Last years gas consumption - kwh",
        units:          :kwh,
        benchmark_code: 'klyr'
      },
      previous_year_kwh: {
        description:  "Previous years gas consumption - kwh (unadjusted for temperature)",
        units:          :kwh,
        benchmark_code: 'kpyr'
      },
      last_year_£: {
        description: 'Last years gas consumption - £ including differential tariff (using historic tariffs)',
        units:  :£,
        benchmark_code: '£lyr'
      },
      last_year_£current: {
        description: 'Last years gas consumption - £ including differential tariff (using latest tariffs)',
        units:  :£current,
        benchmark_code: '€lyr'
      },
      historic_rate_£_per_kwh: {
        description: 'Blended historic tariff over last year',
        units:  :£_per_kwh
      },
      current_rate_£_per_kwh: {
        description: 'Blended current tariff over last year i.e. the latest tariff applied to historic kWh comsumption',
        units:  :£_per_kwh
      },
      previous_year_£: {
        description: 'Previous years gas consumption - £ including differential tariff  (using historic tariffs)',
        units:  :£,
        benchmark_code: '£pyr'
      },
      previous_year_£current: {
        description: 'Previous years gas consumption - £ including differential tariff  (using latest tariffs)',
        units:  :£current,
        benchmark_code: '€pyr'
      },
      last_year_co2: {
        description: 'Last years gas CO2 kg',
        units:  :co2,
        benchmark_code: 'co2y'
      },
      one_year_benchmark_floor_area_kwh: {
        description: 'Last years gas consumption for benchmark/average school, normalised by floor area - kwh',
        units:  {kwh: :gas}
      },
      one_year_benchmark_floor_area_£: {
        description: 'Last years gas consumption for benchmark/average school, normalised by floor area - £ (historic tariff)',
        units:  :£
      },
      one_year_benchmark_floor_area_£current: {
        description: 'Last years gas consumption for benchmark/average school, normalised by floor area - £ (current tariff)',
        units:  :£current
      },
      one_year_saving_versus_benchmark_kwh: {
        description: 'Annual difference in gas consumption versus benchmark/average school - kwh (use adjective for sign)',
        units:  {kwh: :gas}
      },
      one_year_saving_versus_benchmark_£: {
        description: 'Annual difference in gas consumption versus benchmark/average school - £ (use adjective for sign) (historic tariff)',
        units:  {£: :gas}
      },
      one_year_saving_versus_benchmark_£current: {
        description: 'Annual difference in gas consumption versus benchmark/average school - £ (use adjective for sign) (current tariff)',
        units:  :£current
      },
      one_year_saving_versus_benchmark_adjective: {
        description: 'Adjective: higher or lower: gas consumption versus benchmark/average school',
        units:  String
      },

      one_year_exemplar_floor_area_kwh: {
        description: 'Last years gas consumption for exemplar school, normalised by floor area - kwh',
        units:  {kwh: :gas}
      },
      one_year_exemplar_floor_area_£: {
        description: 'Last years gas consumption for exemplar school, normalised by floor area - £ (historic tariff)',
        units:  :£,
        benchmark_code: '£exa'
      },
      one_year_exemplar_floor_area_£current: {
        description: 'Last years gas consumption for exemplar school, normalised by floor area - £ (current tariff)',
        units:  :£current,
        benchmark_code: '€exa'
      },
      one_year_exemplar_floor_area_co2: {
        description: 'Last years gas consumption for exemplar school, normalised by floor area - CO2 kg',
        units:  :co2
      },
      one_year_saving_versus_exemplar_kwh: {
        description: 'Annual difference in gas consumption versus exemplar school - kwh (use adjective for sign)',
        units:  {kwh: :gas}
      },
      one_year_saving_versus_exemplar_£: {
        description: 'Annual difference in gas consumption versus exemplar school - £ (use adjective for sign) (historic tariff)',
        units:  :£,
        benchmark_code: 's£ex'
      },
      one_year_saving_versus_exemplar_£current: {
        description: 'Annual difference in gas consumption versus exemplar school - £ (use adjective for sign) (current tariff)',
        units:  :£current,
        benchmark_code: 's€ex'
      },
      one_year_saving_versus_exemplar_co2: {
        description: 'Annual difference in gas consumption versus exemplar school - CO2 kg (use adjective for sign)',
        units:  :co2
      },
      one_year_saving_versus_exemplar_adjective: {
        description: 'Adjective: higher or lower: gas consumption versus exemplar school',
        units:  String
      },

      one_year_gas_per_pupil_kwh: {
        description: 'Per pupil annual gas usage - kwh - required for PH analysis, not alerts',
        units:  {kwh: :gas},
        benchmark_code: 'kpup'
      },
      one_year_gas_per_pupil_£: {
        description: 'Per pupil annual gas usage - £ - required for PH analysis, not alerts (historic tariff)',
        units:  :£,
        benchmark_code: '£pup'
      },
      one_year_gas_per_pupil_£current: {
        description: 'Per pupil annual gas usage - £ - required for PH analysis, not alerts (current tariff)',
        units:  :£current,
        benchmark_code: '€pup'
      },
      one_year_gas_per_pupil_co2: {
        description: 'Per pupil annual gas usage - co2 - required for PH analysis, not alerts',
        units:  :co2,
        benchmark_code: 'cpup'
      },
      one_year_gas_per_floor_area_co2: {
        description: 'Per floor area annual gas usage - co2 - required for PH analysis, not alerts',
        units:  :co2,
        benchmark_code: 'cfla'
      },
      one_year_gas_per_floor_area_kwh: {
        description: 'Per floor area annual gas usage - kwh - required for PH analysis, not alerts',
        units:  {kwh: :gas}
      },
      one_year_gas_per_floor_area_£: {
        description: 'Per floor area annual gas usage - £ - required for PH analysis, not alerts (historic tariff)',
        units:  :£,
        benchmark_code: 'pfla'
      },
      one_year_gas_per_floor_area_£current: {
        description: 'Per floor area annual gas usage - £ - required for PH analysis, not alerts (current tariff)',
        units:  :£current,
        benchmark_code: '€fla'
      },
      degree_day_adjustment: {
        description: 'Regional degree day adjustment; 60% of adjustment for Gas (not 100% heating consumption), 100% of Storage Heaters',
        units: Float,
        benchmark_code: 'ddaj'
      },
      last_year_degree_days: {
        description: 'Regional degree day adjustment; 60% of adjustment for Gas (not 100% heating consumption), 100% of Storage Heaters',
        units: Float,
        benchmark_code: 'ddly'
      },
      previous_year_degree_days: {
        description: 'Regional degree day adjustment; 60% of adjustment for Gas (not 100% heating consumption), 100% of Storage Heaters',
        units: Float,
        benchmark_code: 'ddpy'
      },
      degree_days_annual_change: {
        description: 'Year on year degree day change',
        units: :relative_percent,
        benchmark_code: 'ddan'
      },
      temperature_adjusted_previous_year_kwh: {
        description: 'Previous year kWh - temperature adjusted',
        units: :kwh,
        benchmark_code: 'kpya'
      },
      temperature_adjusted_percent: {
        description: 'Year on year kwh change temperature adjusted',
        units: :relative_percent,
        benchmark_code: 'adpc'
      },
      one_year_gas_per_pupil_normalised_kwh: {
        description: 'Per pupil annual gas usage - kwh - temperature normalised (internal use only)',
        units:  {kwh: :gas},
        benchmark_code: 'nkpp'
      },
      one_year_gas_per_pupil_normalised_£: {
        description: 'Per pupil annual gas usage - £ - temperature normalised (internal use only) (historic tariff)',
        units:  :£,
        benchmark_code: 'n£pp'
      },
      one_year_gas_per_pupil_normalised_£current: {
        description: 'Per pupil annual gas usage - £ - temperature normalised (internal use only) (current tariff)',
        units:  :£current,
        benchmark_code: 'n€pp'
      },
      one_year_gas_per_floor_area_normalised_kwh: {
        description: 'Per floor area annual gas usage - kwh - temperature normalised (internal use only) (current tariff)',
        units:  {kwh: :gas},
        benchmark_code: 'nkm2'
      },
      one_year_gas_per_floor_area_normalised_£: {
        description: 'Per floor area annual gas usage - £ - temperature normalised (internal use only) (historic tariff)',
        units:  :£,
        benchmark_code: 'n£m2'
      },
      one_year_gas_per_floor_area_normalised_£current: {
        description: 'Per floor area annual gas usage - £ - temperature normalised (internal use only) (current tariff)',
        units:  :£current,
        benchmark_code: 'n€m2'
      },
      per_floor_area_gas_benchmark_£: {
        description: 'Per floor area annual gas usage - £ (current tariff)',
        units:  {£: :gas}
      },
      percent_difference_from_average_per_floor_area: {
        description: 'Percent difference from average (benchmark)',
        units:  :relative_percent,
        benchmark_code: 'pp%d'
      },
      percent_difference_from_exemplar_per_floor_area: {
        description: 'Percent difference from exemplar',
        units:  :relative_percent,
        benchmark_code: 'ep%d'
      },
      percent_difference_adjective: {
        description: 'Adjective relative to average: above, signifantly above, about',
        units: String
      },
      simple_percent_difference_adjective:  {
        description: 'Adjective relative to average: above, about, below',
        units: String
      },
      percent_difference_exemplar_adjective: {
        description: 'Adjective relative to exemplar: above, signifantly above, about',
        units: String
      },
      simple_percent_difference_exemplar_adjective:  {
        description: 'Adjective relative to exemplar: above, about, below',
        units: String
      },
      tariff_has_changed_during_period_text: {
        description: 'Caveat text to explain change in £ tariffs during year period, blank if no change',
        units:  String
      },
      summary: {
        description: 'Description: £spend, adj relative to average - historic tariffs',
        units: String
      },
      summary_current: {
        description: 'Description: £spend, adj relative to average - current tariffs',
        units: String
      }
    }
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    days_amr_data_with_asof_date(@asof_date) >= DAYSINYEAR ? :enough : :not_enough
  end

  protected def max_days_out_of_date_while_still_relevant
    ManagementSummaryTable::MAX_DAYS_OUT_OF_DATE_FOR_1_YEAR_COMPARISON
  end

  private def calculate(asof_date)
    raise EnergySparksNotEnoughDataException, "Not enough data: 1 year of data required, got #{days_amr_data} days" if enough_data == :not_enough
    @degree_day_adjustment = dd_adj(asof_date)
    calculate_annual_change_in_degree_days(asof_date)
    temperature_adjusted_stats(asof_date)

    @last_year_kwh      = kwh(asof_date - DAYSINYEAR, asof_date, :kwh)
    @last_year_£        = kwh(asof_date - DAYSINYEAR, asof_date, :£)
    @last_year_£current = kwh(asof_date - DAYSINYEAR, asof_date, :£current)
    @last_year_co2      = kwh(asof_date - DAYSINYEAR, asof_date, :co2)

    fa  = floor_area(asof_date - DAYSINYEAR, asof_date)
    pup = pupils(asof_date - DAYSINYEAR, asof_date)
    @historic_rate_£_per_kwh = aggregate_meter.amr_data.blended_rate(:kwh, :£,        asof_date - DAYSINYEAR, asof_date)
    @current_rate_£_per_kwh  = aggregate_meter.amr_data.blended_rate(:kwh, :£current, asof_date - DAYSINYEAR, asof_date)

    prev_date = asof_date - DAYSINYEAR - 1
    @previous_year_kwh      = kwh(prev_date - DAYSINYEAR, prev_date, :kwh)
    @previous_year_£        = kwh(prev_date - DAYSINYEAR, prev_date, :£)
    @previous_year_£current = kwh(prev_date - DAYSINYEAR, prev_date, :£current)

    @one_year_benchmark_floor_area_kwh   = BenchmarkMetrics::BENCHMARK_GAS_USAGE_PER_M2 * fa / @degree_day_adjustment
    # benchmark £ using same tariff as school not benchmark tariff
    @one_year_benchmark_floor_area_£        = @one_year_benchmark_floor_area_kwh * @historic_rate_£_per_kwh
    @one_year_benchmark_floor_area_£current = @one_year_benchmark_floor_area_kwh * @current_rate_£_per_kwh
    @one_year_benchmark_floor_area_co2 = gas_co2(@one_year_benchmark_floor_area_kwh)

    @one_year_saving_versus_benchmark_kwh       = @last_year_kwh      - @one_year_benchmark_floor_area_kwh
    @one_year_saving_versus_benchmark_£         = @last_year_£        - @one_year_benchmark_floor_area_£
    @one_year_saving_versus_benchmark_£current  = @last_year_£current - @one_year_benchmark_floor_area_£current
    @one_year_savings_versus_benchmark_co2 = @last_year_co2 - @one_year_benchmark_floor_area_co2

    @one_year_exemplar_floor_area_kwh       = BenchmarkMetrics::EXEMPLAR_GAS_USAGE_PER_M2 * fa / @degree_day_adjustment
    @one_year_exemplar_floor_area_£         = @one_year_exemplar_floor_area_kwh * @historic_rate_£_per_kwh
    @one_year_exemplar_floor_area_£current  = @one_year_exemplar_floor_area_kwh * @current_rate_£_per_kwh
    @one_year_exemplar_floor_area_co2   = gas_co2(@one_year_exemplar_floor_area_kwh)


    @one_year_saving_versus_exemplar_kwh      = @last_year_kwh      - @one_year_exemplar_floor_area_kwh
    @one_year_saving_versus_exemplar_£        = @last_year_£        - @one_year_exemplar_floor_area_£
    @one_year_saving_versus_exemplar_£current = @last_year_£current - @one_year_exemplar_floor_area_£current
    @one_year_saving_versus_exemplar_co2      = @last_year_co2      - @one_year_exemplar_floor_area_co2

    @one_year_gas_per_pupil_kwh           = @last_year_kwh      / pup
    @one_year_gas_per_pupil_£             = @last_year_£        / pup
    @one_year_gas_per_pupil_£current      = @last_year_£current / pup
    @one_year_gas_per_floor_area_kwh      = @last_year_kwh      / fa
    @one_year_gas_per_floor_area_£        = @last_year_£        / fa
    @one_year_gas_per_floor_area_£current = @last_year_£current / fa

    @one_year_gas_per_pupil_co2       = @last_year_co2  / pup
    @one_year_gas_per_floor_area_co2  = @last_year_co2  / fa

    @one_year_gas_per_pupil_normalised_kwh          = @one_year_gas_per_pupil_kwh           * @degree_day_adjustment
    @one_year_gas_per_pupil_normalised_£            = @one_year_gas_per_pupil_£             * @degree_day_adjustment
    @one_year_gas_per_pupil_normalised_£current     = @one_year_gas_per_pupil_£current      * @degree_day_adjustment
    @one_year_gas_per_floor_area_normalised_kwh     = @one_year_gas_per_floor_area_kwh      * @degree_day_adjustment
    @one_year_gas_per_floor_area_normalised_£       = @one_year_gas_per_floor_area_£        * @degree_day_adjustment
    @one_year_gas_per_floor_area_normalised_£current= @one_year_gas_per_floor_area_£current * @degree_day_adjustment

    @per_floor_area_gas_benchmark_£ = @one_year_benchmark_floor_area_£ / fa
    @percent_difference_from_average_per_floor_area = percent_change(@one_year_benchmark_floor_area_kwh, @last_year_kwh)
    @percent_difference_from_exemplar_per_floor_area = percent_change(@one_year_exemplar_floor_area_kwh, @last_year_kwh)

    #BACKWARDS COMPATIBILITY: previously would have failed here as percent_change can return nil
    raise_calculation_error_if_missing(percent_difference_from_average_per_floor_area: @percent_difference_from_average_per_floor_area)

    assign_commmon_saving_variables(
      one_year_saving_kwh: @one_year_saving_versus_exemplar_kwh,
      one_year_saving_£: @one_year_saving_versus_exemplar_£,
      one_year_saving_co2: @one_year_saving_versus_exemplar_co2)

    # rating: benchmark value = 4.0, exemplar = 10.0
    percent_from_benchmark_to_exemplar = (@last_year_kwh - @one_year_benchmark_floor_area_kwh) / (@one_year_exemplar_floor_area_kwh - @one_year_benchmark_floor_area_kwh)
    uncapped_rating = percent_from_benchmark_to_exemplar * (10.0 - 4.0) + 4.0
    @rating = [[uncapped_rating, 10.0].min, 0.0].max.round(2)

    @tariff_has_changed_during_period_text = annual_tariff_change_text(asof_date)

    @status = @rating < 6.0 ? :bad : :good

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  def saving_table_data
    cost_saving_header_text = 'Cost saving if matched exemplar'
    cost_saving_header_text += ' at current tariff' unless @last_year_£ == @last_year_£current

    {
      units:   [:kwh, :kwh, :kwh, :£current],
      header:  ['Your school', 'Well managed school', 'Exemplar school', cost_saving_header_text],
      data:    [[@last_year_kwh, @one_year_benchmark_floor_area_kwh, @one_year_exemplar_floor_area_kwh, @one_year_saving_versus_exemplar_£current]]
    }
  end

  def benchmark_chart_data
    @benchmark_chart_data ||= {
      school: {
        kwh:      @last_year_kwh,
        £:        @last_year_£,
        £current: @last_year_£current,
        co2:      @last_year_co2
      },
      benchmark: {
        kwh:      @one_year_benchmark_floor_area_kwh,
        £:        @one_year_benchmark_floor_area_£,
        £current: @one_year_benchmark_floor_area_£current,
        co2:      @one_year_benchmark_floor_area_co2,

        saving: {
          kwh:       @one_year_saving_versus_benchmark_kwh,
          £:         @one_year_saving_versus_benchmark_£,
          £current:  @one_year_saving_versus_benchmark_£current,
          percent:   @percent_difference_from_average_per_floor_area,
          co2:       @one_year_savings_versus_benchmark_co2
        }
      },
      exemplar: {
        kwh:      @one_year_exemplar_floor_area_kwh,
        £:        @one_year_exemplar_floor_area_£,
        £current: @one_year_exemplar_floor_area_£current,
        co2:      @one_year_exemplar_floor_area_co2,

        saving: {
          kwh:       @one_year_saving_versus_exemplar_kwh,
          £:         @one_year_saving_versus_exemplar_£,
          £current:  @one_year_saving_versus_exemplar_£current,
          percent:   @percent_difference_from_exemplar_per_floor_area,
          co2:       @one_year_saving_versus_exemplar_co2
        }
      }
    }
  end

  def one_year_saving_versus_exemplar_adjective
    return nil if @one_year_saving_versus_exemplar_kwh.nil?
    Adjective.adjective_for(@one_year_saving_versus_exemplar_kwh)
  end

  def one_year_saving_versus_benchmark_adjective
    return nil if @one_year_saving_versus_benchmark_kwh.nil?
    Adjective.adjective_for(@one_year_saving_versus_benchmark_kwh)
  end

  def percent_difference_adjective
    return "" if @percent_difference_from_average_per_floor_area.nil?
    Adjective.relative(@percent_difference_from_average_per_floor_area, :relative_to_1)
  end

  def simple_percent_difference_adjective
    return "" if @percent_difference_from_average_per_floor_area.nil?
    Adjective.relative(@percent_difference_from_average_per_floor_area, :simple_relative_to_1)
  end

  def percent_difference_exemplar_adjective
    return "" if @percent_difference_from_exemplar_per_floor_area.nil?
    Adjective.relative(@percent_difference_from_exemplar_per_floor_area, :relative_to_1)
  end

  def simple_percent_difference_exemplar_adjective
    return "" if @percent_difference_from_exemplar_per_floor_area.nil?
    Adjective.relative(@percent_difference_from_exemplar_per_floor_area, :simple_relative_to_1)
  end

  def summary
    I18n.t("analytics.annual_cost_with_adjective",
      cost: FormatUnit.format(:£, @last_year_£, :text),
      relative_percent: FormatUnit.format(:relative_percent, @percent_difference_from_average_per_floor_area, :text),
      adjective: simple_percent_difference_adjective)
  end

  def summary_current
    I18n.t("analytics.annual_cost_with_adjective",
      cost: FormatUnit.format(:£, @last_year_£current, :text),
      relative_percent: FormatUnit.format(:relative_percent, @percent_difference_from_average_per_floor_area, :text),
      adjective: simple_percent_difference_adjective)
  end

  private

  def dd_adj(asof_date)
    # overriden to full rather than 60% adjustment for storage heaters
    BenchmarkMetrics.normalise_degree_days(@school.temperatures, @school.holidays, :gas, asof_date)
  end

  def last_year_date_range(asof_date)
    last_year_start_date = asof_date - DAYSINYEAR
    last_year_start_date..asof_date
  end

  def previous_year_date_range(asof_date)
    ly = last_year_date_range(asof_date)
    previous_year_end_date = ly.first - 1
    previous_year_start_date = previous_year_end_date - DAYSINYEAR
    previous_year_start_date..previous_year_end_date
  end

  def years_date_ranges_x2(asof_date)
    [previous_year_date_range(asof_date), last_year_date_range(asof_date)]
  end

  def temperature_adjusted_stats(asof_date)
    py, ly = years_date_ranges_x2(asof_date)
    model = calculate_model(asof_date)
    stats = model.heating_change_statistics(py, ly)
    unpack_temperature_adjusted_stats(stats) unless stats.nil?
  end

  def unpack_temperature_adjusted_stats(stats)
    @temperature_adjusted_previous_year_kwh = stats[:previous_year][:adjusted_annual_kwh]
    @temperature_adjusted_percent           = stats[:change][:adjusted_percent]
  end

  def calculate_annual_change_in_degree_days(asof_date)
    py, ly = years_date_ranges_x2(asof_date)

    @last_year_degree_days     = @school.temperatures.degree_days_in_date_range(ly.first, ly.last)
    @previous_year_degree_days = @school.temperatures.degree_days_in_date_range(py.first, py.last)

    @degree_days_annual_change = (@last_year_degree_days - @previous_year_degree_days) / @previous_year_degree_days
  end

  def kwh(date1, date2, data_type = :kwh)
    if aggregate_meter.amr_data.start_date > date1 || aggregate_meter.amr_data.end_date < date2
      nil
    else
      aggregate_meter.amr_data.kwh_date_range(date1, date2, data_type)
    end
  rescue EnergySparksNotEnoughDataException=> e
    nil
  end
end
