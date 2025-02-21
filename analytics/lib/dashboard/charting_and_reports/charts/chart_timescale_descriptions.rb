# Helper class that interprets the `:timescale` key in a chart configuration
# to produce a label or description of the time period
class ChartTimeScaleDescriptions
  TIMESCALE_TYPES = 'charts.timescale_name'.freeze

  def initialize(chart_config)
    @chart_config = chart_config
  end

  def self.timescale_name(timescale_symbol) # also used by drilldown
    #using default rather than falling back to :none
    I18n.t("charts.timescale_name.#{timescale_symbol}", default: '')
  end

  def self.convert_timescale_to_array(timescale)
    timescales = []
    if timescale.is_a?(Symbol)
      timescales = [ {timescale => 0}]
    elsif timescale.is_a?(Hash)
      timescales = [ timescale ]
    elsif timescale.is_a?(Array)
      timescales = timescale
    else
      raise EnergySparksUnexpectedStateException, "Unsupported timescale #{timescale} for chart manipulation"
    end
    timescales
  end

  public def timescale_description
    self.class.interpret_timescale_description(@chart_config[:timescale])
  end

  def self.interpret_timescale_description(timescale)
    timescales = convert_timescale_to_array(timescale)
    timescale = timescales[0]
    if timescale.is_a?(Hash) && !timescale.empty? && timescale.keys[0] == :daterange
      impute_description_from_date_range(timescale.values[0])
    elsif known_type?(timescale)
      timescale_name(timescale)
    elsif timescale.is_a?(Hash) && !timescale.empty? && known_type?(timescale.keys[0])
      timescale_name(timescale.keys[0])
    else
      timescale_name(:period)
    end
  end

  def self.days_in_date_range(daterange)
    (daterange.last - daterange.first + (daterange.exclude_end? ? 0 : 1)).to_i
  end

  def self.impute_description_from_date_range(date_range)
    days = days_in_date_range(date_range)
    case days
    when 1
      timescale_name(:day)
    when 7
      timescale_name(:week)
    when 28..31
      timescale_name(:month)
    when 350..380
      timescale_name(:year)
    else
      if days > 380
        timescale_name(:years)
      elsif days % 7 == 0
        # ends up with duplicate number e.g. 'Move forward 1 2 weeks' TODO(PH, 13Sep2019) fix further up hierarchy
        I18n.t("#{TIMESCALE_TYPES}.n_weeks", count: days / 7)
      else
        timescale_name(:daterange)
      end
    end
  end

  def self.known_type?(timescale)
    #test for :none as fallback behaviour for any code relying on
    #previous behaviour
    I18n.t(TIMESCALE_TYPES).key?(timescale) || timescale == :none
  end
end
