#======================== Electricity Annual kWh Versus Benchmark =============
require_relative '../common/alert_analysis_base.rb'
require_relative '../common/alert_floor_area_pupils_mixin.rb'

class AlertElectricityAnnualVersusBenchmark < AlertElectricityOnlyBase
  DAYSINYEAR = 363 # 364 days inclusive - consistent with charts which are 7 days * 52 weeks
  include AlertFloorAreaMixin
  attr_reader :last_year_kwh, :last_year_£, :previous_year_£, :last_year_co2
  attr_reader :last_year_£current, :previous_year_£current, :previous_year_kwh

  attr_reader :one_year_benchmark_by_pupil_kwh, :one_year_benchmark_by_pupil_£
  attr_reader :one_year_saving_versus_benchmark_kwh, :one_year_saving_versus_benchmark_£

  attr_reader :one_year_exemplar_by_pupil_kwh, :one_year_exemplar_by_pupil_£
  attr_reader :one_year_saving_versus_exemplar_kwh, :one_year_saving_versus_exemplar_£, :one_year_saving_versus_exemplar_co2

  attr_reader :one_year_electricity_per_pupil_kwh, :one_year_electricity_per_pupil_£, :one_year_electricity_per_pupil_co2
  attr_reader :one_year_electricity_per_floor_area_kwh, :one_year_electricity_per_floor_area_£

  attr_reader :one_year_benchmark_by_pupil_£current, :one_year_saving_versus_benchmark_£current
  attr_reader :one_year_exemplar_by_pupil_£current, :one_year_saving_versus_exemplar_£current
  attr_reader :one_year_electricity_per_pupil_£current, :one_year_electricity_per_floor_area_£current
  attr_reader :one_year_electricity_per_floor_area_co2
  attr_reader :per_pupil_electricity_benchmark_£current

  attr_reader :per_pupil_electricity_benchmark_£
  attr_reader :percent_difference_from_average_per_pupil
  attr_reader :percent_difference_from_exemplar_per_pupil
  attr_reader :tariff_has_changed_during_period_text

  attr_reader :historic_rate_£_per_kwh, :current_rate_£_per_kwh

  def initialize(school)
    super(school, :annualelectricitybenchmark)
  end

  def self.template_variables
    specific = {'Annual electricity usage versus benchmark' => TEMPLATE_VARIABLES}
    specific.merge(self.superclass.template_variables)
  end

  TEMPLATE_VARIABLES = {
    last_year_kwh: {
      description: 'Last years electricity consumption - kwh',
      units:  {kwh: :electricity},
      benchmark_code: 'klyr'
    },
    last_year_£: {
      description: 'Last years electricity consumption - £ including differential tariff (historic tariffs)',
      units:  :£,
      benchmark_code: '£lyr'
    },
    last_year_£current: {
      description: 'Last years electricity consumption - £ including differential tariff  (current tariffs)',
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
    previous_year_kwh: {
      description: 'Previous years electricity consumption kWh',
      units:  :kwh,
      benchmark_code: 'kpyr'
    },
    previous_year_£: {
      description: 'Previous years electricity consumption - £ including differential tariff (historic tariffs)',
      units:  :£,
      benchmark_code: '£pyr'
    },
    previous_year_£current: {
      description: 'Previous years electricity consumption - £ including differential tariff (current tariffs)',
      units:  :£current,
      benchmark_code: '€pyr'
    },
    last_year_co2: {
      description: 'Last years electricity CO2 kg',
      units:  :co2,
      benchmark_code: 'co2y'
    },
    one_year_benchmark_by_pupil_kwh: {
      description: 'Last years electricity consumption for benchmark/average school, normalised by pupil numbers - kwh',
      units:  {kwh: :electricity}
    },
    one_year_benchmark_by_pupil_£: {
      description: 'Last years electricity consumption for benchmark/average school, normalised by pupil numbers - £ (historic tariffs)',
      units:  :£
    },
    one_year_benchmark_by_pupil_£current: {
      description: 'Last years electricity consumption for benchmark/average school, normalised by pupil numbers - £ (current tariffs)',
      units:  :£current
    },
    one_year_saving_versus_benchmark_kwh: {
      description: 'Annual difference in electricity consumption versus benchmark/average school - kwh (use adjective for sign)',
      units:  {kwh: :electricity}
    },
    one_year_saving_versus_benchmark_£: {
      description: 'Annual difference in electricity consumption versus benchmark/average school - £ (use adjective for sign) (historic tariffs)',
      units:  :£
    },
    one_year_saving_versus_benchmark_£current: {
      description: 'Annual difference in electricity consumption versus benchmark/average school - £ (use adjective for sign) (current tariffs)',
      units:  :£current
    },
    one_year_saving_versus_benchmark_adjective: {
      description: 'Adjective: higher or lower: electricity consumption versus benchmark/average school',
      units: String
    },
    one_year_saving_versus_exemplar_adjective: {
      description: 'Adjective: higher or lower: electricity consumption versus exemplar school',
      units: String
    },
    one_year_exemplar_by_pupil_kwh: {
      description: 'Last years electricity consumption for exemplar school, normalised by pupil numbers - kwh',
      units:  {kwh: :electricity}
    },
    one_year_exemplar_by_pupil_£: {
      description: 'Last years electricity consumption for exemplar school, normalised by pupil numbers - £ (historic tariffs)',
      units:  :£
    },
    one_year_exemplar_by_pupil_£current: {
      description: 'Last years electricity consumption for exemplar school, normalised by pupil numbers - £ (current tariffs)',
      units:  :£current
    },
    one_year_saving_versus_exemplar_kwh: {
      description: 'Annual difference in electricity consumption versus exemplar school - kwh (use adjective for sign)',
      units:  {kwh: :electricity}
    },
    one_year_saving_versus_exemplar_£: {
      description: 'Annual difference in electricity consumption versus exemplar school - £ (use adjective for sign) (historic tariffs)',
      units:  :£,
      benchmark_code: '£esav'
    },
    one_year_saving_versus_exemplar_£current: {
      description: 'Annual difference in electricity consumption versus exemplar school - £ (use adjective for sign) (current tariffs)',
      units:  :£current,
      benchmark_code: '€esav'
    },
    one_year_saving_versus_exemplar_co2: {
      description: 'Annual difference in electricity consumption versus exemplar school - co2 (use adjective for sign)',
      units:  :c02,
    },
    one_year_electricity_per_pupil_kwh: {
      description: 'Per pupil annual electricity usage - kwh - required for PH analysis, not alerts',
      units:  {kwh: :electricity},
      benchmark_code: 'kpup'
    },
    one_year_electricity_per_pupil_£: {
      description: 'Per pupil annual electricity usage - £ - required for PH analysis, not alerts (historic tariffs)',
      units:  :£,
      benchmark_code: '£pup'
    },
    one_year_electricity_per_pupil_£current: {
      description: 'Per pupil annual electricity usage - £ - required for PH analysis, not alerts (current tariffs)',
      units:  :£current,
      benchmark_code: '€pup'
    },
    one_year_electricity_per_pupil_co2: {
      description: 'Per pupil annual electricity usage - co2 - required for PH analysis, not alerts',
      units:  :co2,
      benchmark_code: 'cpup'
    },
    one_year_electricity_per_floor_area_co2: {
      description: 'Per floor area annual electricity usage - co2 - required for PH analysis, not alerts',
      units:  :co2,
      benchmark_code: 'c£m2'
    },
    one_year_electricity_per_floor_area_kwh: {
      description: 'Per floor area annual electricity usage - kwh - required for PH analysis, not alerts',
      units:  {kwh: :electricity}
    },
    one_year_electricity_per_floor_area_£: {
      description: 'Per floor area annual electricity usage - £ - required for PH analysis, not alerts (historic tariffs)',
      units:  :£
    },
    one_year_electricity_per_floor_area_£current: {
      description: 'Per floor area annual electricity usage - £ - required for PH analysis, not alerts (current tariffs)',
      units:  :£current
    },
    per_pupil_electricity_benchmark_£: {
      description: 'Per pupil annual electricity usage - £  (historic tariffs)',
      units:  :£
    },
    per_pupil_electricity_benchmark_£current: {
      description: 'Per pupil annual electricity usage - £  (current tariffs)',
      units:  :£current
    },
    percent_difference_from_average_per_pupil: {
      description: 'Percent difference from average',
      units:  :relative_percent,
      benchmark_code: 'pp%d'
    },
    percent_difference_from_exemplar_per_pupil: {
      description: 'Percent difference from exemplar',
      units:  :relative_percent,
      benchmark_code: 'ep%d'
    },
    percent_difference_adjective: {
      description: 'Adjective relative to average: above, signifantly above, about v. benchmark',
      units: String
    },
    percent_difference_exemplar_adjective: {
      description: 'Adjective relative to average: above, signifantly above, about',
      units: String
    },
    simple_percent_difference_adjective:  {
      description: 'Adjective relative to average: above, about, below (v. benchamrk)',
      units: String
    },
    simple_percent_difference_exemplar_adjective:  {
      description: 'Adjective relative to average: above, about, below (v. exemplar)',
      units: String
    },
    tariff_has_changed_during_period_text: {
      description: 'Caveat text to explain change in £ tariffs during year period, blank if no change',
      units:  String
    },
    summary: {
      description: 'Description: £spend, adj relative to average (historic tariffs)',
      units: String
    },
    summary_current: {
      description: 'Description: £spend, adj relative to average (current tariffs)',
      units: String
    }
  }

  def enough_data
    days_amr_data_with_asof_date(@asof_date) >= DAYSINYEAR ? :enough : :not_enough
  end

  protected def max_days_out_of_date_while_still_relevant
    ManagementSummaryTable::MAX_DAYS_OUT_OF_DATE_FOR_1_YEAR_COMPARISON
  end

  private def calculate(asof_date)
    raise EnergySparksNotEnoughDataException, "Not enough data: 1 year of data required, got #{days_amr_data} days" if enough_data == :not_enough
    @last_year_kwh      = kwh(asof_date - DAYSINYEAR, asof_date, :kwh)
    @last_year_£        = kwh(asof_date - DAYSINYEAR, asof_date, :£)
    @last_year_£current = kwh(asof_date - DAYSINYEAR, asof_date, :£current)
    @last_year_co2      = kwh(asof_date - DAYSINYEAR, asof_date, :co2)

    fa  = floor_area(asof_date - DAYSINYEAR, asof_date)
    pup = pupils(asof_date - DAYSINYEAR, asof_date)
    @historic_rate_£_per_kwh = aggregate_meter.amr_data.blended_rate(:kwh, :£,        asof_date - DAYSINYEAR, asof_date)
    @current_rate_£_per_kwh  = aggregate_meter.amr_data.blended_rate(:kwh, :£current, asof_date - DAYSINYEAR, asof_date)

    @historic_rate_£_per_kwh = historic_blended_rate_£_per_kwh
    @current_rate_£_per_kwh  = current_blended_rate_£_per_kwh

    prev_date = asof_date - DAYSINYEAR - 1
    one_year_before_prev_date = prev_date - DAYSINYEAR
    #The following three variables need an extra years worth of data
    #we only use them on the school comparison page. Check whether we have
    #the extra data before calculating them. Stops error with schools that
    #have >1 but <2 years of data
    #
    #These variables might be better generated by AlertLongTermTrend which
    #only runs if there is >2 years of data and already produces similar data
    if has_full_previous_years_worth_of_data?(one_year_before_prev_date)
      @previous_year_kwh      = kwh(one_year_before_prev_date, prev_date, :kwh)
      @previous_year_£        = kwh(one_year_before_prev_date, prev_date, :£)
      @previous_year_£current = kwh(one_year_before_prev_date, prev_date, :£current)
    end

    @one_year_benchmark_by_pupil_kwh            = BenchmarkMetrics.benchmark_annual_electricity_usage_kwh(school_type, pup)
    @one_year_benchmark_by_pupil_£current       = @one_year_benchmark_by_pupil_kwh * @current_rate_£_per_kwh
    @one_year_benchmark_by_pupil_£              = @one_year_benchmark_by_pupil_kwh * @historic_rate_£_per_kwh
    @one_year_benchmark_by_pupil_co2 = @one_year_benchmark_by_pupil_kwh * blended_co2_per_kwh

    @one_year_saving_versus_benchmark_kwh       = @last_year_kwh - @one_year_benchmark_by_pupil_kwh
    @one_year_saving_versus_benchmark_£         = @one_year_saving_versus_benchmark_kwh * @historic_rate_£_per_kwh
    @one_year_saving_versus_benchmark_£current  = @one_year_saving_versus_benchmark_kwh * @current_rate_£_per_kwh

    @one_year_saving_versus_benchmark_kwh       = @one_year_saving_versus_benchmark_kwh.magnitude
    @one_year_saving_versus_benchmark_£         = @one_year_saving_versus_benchmark_£.magnitude
    @one_year_saving_versus_benchmark_£current  = @one_year_saving_versus_benchmark_£current.magnitude
    @one_year_saving_versus_benchmark_co2 = @one_year_saving_versus_benchmark_kwh  * blended_co2_per_kwh

    @one_year_exemplar_by_pupil_kwh             = BenchmarkMetrics.exemplar_annual_electricity_usage_kwh(school_type, pup)
    @one_year_exemplar_by_pupil_£               = @one_year_exemplar_by_pupil_kwh * @historic_rate_£_per_kwh
    @one_year_exemplar_by_pupil_£current        = @one_year_exemplar_by_pupil_kwh * @current_rate_£_per_kwh
    @one_year_exemplar_by_pupil_co2 = @one_year_exemplar_by_pupil_kwh * blended_co2_per_kwh

    @one_year_saving_versus_exemplar_kwh      = @last_year_kwh - @one_year_exemplar_by_pupil_kwh
    @one_year_saving_versus_exemplar_£        = @one_year_saving_versus_exemplar_kwh * @historic_rate_£_per_kwh
    @one_year_saving_versus_exemplar_£current = @one_year_saving_versus_exemplar_kwh * @current_rate_£_per_kwh
    @one_year_saving_versus_exemplar_co2      = @one_year_saving_versus_exemplar_kwh * blended_co2_per_kwh

    @one_year_saving_versus_exemplar_kwh      = @one_year_saving_versus_exemplar_kwh.magnitude
    @one_year_saving_versus_exemplar_£        = @one_year_saving_versus_exemplar_£.magnitude
    @one_year_saving_versus_exemplar_£current = @one_year_saving_versus_exemplar_£current.magnitude
    @one_year_saving_versus_exemplar_co2      = @one_year_saving_versus_exemplar_co2.magnitude

    @one_year_electricity_per_pupil_kwh           = @last_year_kwh      / pup
    @one_year_electricity_per_pupil_£             = @last_year_£        / pup
    @one_year_electricity_per_pupil_£current      = @last_year_£current / pup
    @one_year_electricity_per_pupil_co2           = @last_year_co2      / pup
    @one_year_electricity_per_floor_area_kwh      = @last_year_kwh      / fa
    @one_year_electricity_per_floor_area_£        = @last_year_£        / fa
    @one_year_electricity_per_floor_area_£current = @last_year_£current / fa
    @one_year_electricity_per_floor_area_co2      = @last_year_co2      / fa

    assign_commmon_saving_variables(
      one_year_saving_kwh: @one_year_saving_versus_exemplar_kwh,
      one_year_saving_£: @one_year_saving_versus_exemplar_£current,
      one_year_saving_co2: @one_year_saving_versus_exemplar_co2)

    @per_pupil_electricity_benchmark_£          = @one_year_benchmark_by_pupil_£ / pup
    @per_pupil_electricity_benchmark_£current   = @one_year_benchmark_by_pupil_£current / pup
    @percent_difference_from_average_per_pupil  = percent_change(@one_year_benchmark_by_pupil_kwh, @last_year_kwh)
    @percent_difference_from_exemplar_per_pupil = percent_change(@one_year_exemplar_by_pupil_kwh, @last_year_kwh)

    #BACKWARDS COMPATIBILITY: previously would have failed here as percent_change can return nil
    raise_calculation_error_if_missing(percent_difference_from_average_per_pupil: @percent_difference_from_average_per_pupil)

    # rating: benchmark value = 4.0, exemplar = 10.0
    percent_from_benchmark_to_exemplar = (@last_year_kwh - @one_year_benchmark_by_pupil_kwh) / (@one_year_exemplar_by_pupil_kwh - @one_year_benchmark_by_pupil_kwh)
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
      data:    [[@last_year_kwh, @one_year_benchmark_by_pupil_kwh, @one_year_exemplar_by_pupil_kwh, @one_year_saving_versus_exemplar_£current]]
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
        kwh:      @one_year_benchmark_by_pupil_kwh,
        £:        @one_year_benchmark_by_pupil_£,
        £current: @one_year_benchmark_by_pupil_£current,
        co2:      @one_year_benchmark_by_pupil_co2,

        saving: {
          kwh:       @one_year_saving_versus_benchmark_kwh,
          £:         @one_year_saving_versus_benchmark_£,
          £current:  @one_year_saving_versus_benchmark_£current,
          percent:   @percent_difference_from_average_per_pupil,
          co2:       @one_year_saving_versus_benchmark_co2
        }
      },
      exemplar: {
        kwh:      @one_year_exemplar_by_pupil_kwh,
        £:        @one_year_exemplar_by_pupil_£,
        £current: @one_year_exemplar_by_pupil_£current,
        co2:      @one_year_exemplar_by_pupil_co2,

        saving: {
          kwh:       @one_year_saving_versus_exemplar_kwh,
          £:         @one_year_saving_versus_exemplar_£,
          £current:  @one_year_saving_versus_exemplar_£current,
          percent:   @percent_difference_from_exemplar_per_pupil,
          co2:       @one_year_saving_versus_exemplar_co2
        }
      }
    }
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def one_year_saving_versus_exemplar_adjective
    return nil if @one_year_saving_versus_exemplar_kwh.nil?
    Adjective.adjective_for(@one_year_saving_versus_exemplar_kwh)
  end

  def one_year_saving_versus_benchmark_adjective
    return nil if @one_year_saving_versus_benchmark_kwh.nil?
    Adjective.adjective_for(@one_year_saving_versus_benchmark_kwh)
  end

  def one_year_saving_versus_exemplar_adjective
    return nil if @one_year_saving_versus_exemplar_kwh.nil?
    Adjective.adjective_for(@one_year_saving_versus_exemplar_kwh)
  end

  def percent_difference_adjective
    return "" if @percent_difference_from_average_per_pupil.nil?
    Adjective.relative(@percent_difference_from_average_per_pupil, :relative_to_1)
  end

  def simple_percent_difference_adjective
    return "" if @percent_difference_from_average_per_pupil.nil?
    Adjective.relative(@percent_difference_from_average_per_pupil, :simple_relative_to_1)
  end

  def percent_difference_exemplar_adjective
    return "" if @percent_difference_from_exemplar_per_pupil.nil?
    Adjective.relative(@percent_difference_from_exemplar_per_pupil, :relative_to_1)
  end

  def simple_percent_difference_exemplar_adjective
    return "" if @percent_difference_from_exemplar_per_pupil.nil?
    Adjective.relative(@percent_difference_from_exemplar_per_pupil, :simple_relative_to_1)
  end

  def summary
    I18n.t("analytics.annual_cost_with_adjective",
      cost: FormatEnergyUnit.format(:£, @last_year_£, :text),
      relative_percent: FormatEnergyUnit.format(:relative_percent, @percent_difference_from_average_per_pupil, :text),
      adjective: simple_percent_difference_adjective)
  end

  def summary_current
    I18n.t("analytics.annual_cost_with_adjective",
      cost: FormatEnergyUnit.format(:£, @last_year_£current, :text),
      relative_percent: FormatEnergyUnit.format(:relative_percent, @percent_difference_from_average_per_pupil, :text),
      adjective: simple_percent_difference_adjective)
  end

  def has_full_previous_years_worth_of_data?(earlier_date)
    amr_data = @school.aggregated_electricity_meters.amr_data
    amr_data.start_date <= earlier_date
  end

  def kwh(date1, date2, data_type = :kwh)
    amr_data = @school.aggregated_electricity_meters.amr_data
    amr_data.kwh_date_range(date1, date2, data_type)
  rescue EnergySparksNotEnoughDataException=> e
    nil
  end
end
