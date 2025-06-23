require 'bigdecimal'

class FormatEnergyUnit
  class InternalErrorNonInfiniteValue < StandardError; end

  ENERGY_UNITS      = 'analytics.energy_units'.freeze
  INFINITY          = 'analytics.units.infinity'.freeze
  NEGATIVE_INFINITY = 'analytics.units.infinity_negative'.freeze
  NAN               = 'analytics.units.nan'.freeze
  MINUTES           = 'analytics.units.minutes'.freeze
  HOURS             = 'analytics.units.hours'.freeze
  DAYS              = 'analytics.units.days'.freeze
  WEEKS             = 'analytics.units.weeks'.freeze
  MONTHS            = 'analytics.units.months'.freeze
  YEARS             = 'analytics.units.years'.freeze

  ZERO = '0'.freeze

  def self.percent_to_1_dp(val, medium = :html)
    I18n.t(key_for_unit(:percent, medium), value: sprintf('%.1f', val * 100.0))
  end

  def self.format(unit, value, medium = :text, convert_missing_types_to_strings = false, in_table = false, user_numeric_comprehension_level = :ks2)
    unit_options = {}
    if unit.is_a?(Hash)
      if unit.key?(:substitute_nil)
        return unit[:substitute_nil] if value.nil? || value == unit[:substitute_nil]
        unit = unit[:units]
      elsif unit.key?(:options)
        unit_options = unit[:options]
        unit = unit[:units]
      end
    end
    format_private(unit, value, medium, convert_missing_types_to_strings, in_table, user_numeric_comprehension_level, unit_options)
  end

  private_class_method def self.format_private(unit, value, medium, convert_missing_types_to_strings, in_table, user_numeric_comprehension_level, unit_options)
    return value if medium == :raw || no_recent_or_not_enough_data?(value)
    return '' if value.nil? #  && in_table - PH 20Nov2019 experimental change to tidying blank cells on heads summary table
    unit = unit.keys[0] if unit.is_a?(Hash) # if unit = {kwh: :gas} - ignore the :gas for formatting purposes
    return scale_num(value, false, user_numeric_comprehension_level).to_s if unit == Float

    #From inspection this only seems to be used via HtmlTableFormatting.format_value
    #FormatEnergyUnit.format(row_units, val, :html, true, table_format, precision)
    #This line of code means that any unknown units in the table will be converted to a string
    #all others will be formatted to the specified precision
    return value.to_s if convert_missing_types_to_strings && !known_unit?(unit)
    check_units(unit)

    if %i[£ £_0dp £_per_kwh £_per_kva £current £_per_kw].include?(unit)
      format_pounds(unit, value, medium, user_numeric_comprehension_level, unit == :£_0dp)
    elsif unit == :£_range
      format_pound_range(value, medium, user_numeric_comprehension_level)
    elsif unit == :r2
      sprintf('%.2f', value)
    elsif unit == :temperature
      format_temperature(value)
    elsif unit == :school_name
      value
    elsif %i[percent percent_0dp relative_percent relative_percent_0dp].include?(unit)
      format_percent(value, unit, user_numeric_comprehension_level, medium, unit_options)
    elsif unit == :comparison_percent
      format_comparison_percent(value, medium)
    elsif unit == :years_range
      format_years_range(value)
    elsif unit == :years
      format_time(value)
    elsif unit == :days
      format_days(value)
    elsif unit == :date
      format_date(value, '%A %e %b %Y')
    elsif unit == :date_mmm_yyyy
      format_date(value, '%b %Y')
    elsif unit == :datetime
      format_date(value, '%A %e %b %Y %H:%M')
    elsif unit == :timeofday || unit == :fuel_type
      value.to_s
    else
      default_format(unit, value, medium, in_table, user_numeric_comprehension_level)
    end
  end

  #This is the default formatter used by most of the units, except for the dates,
  #times, money and percentages. Formats the number and then adds the units
  private_class_method def self.default_format(unit, value, medium, in_table, user_numeric_comprehension_level)
    value = scale_num(value, false, user_numeric_comprehension_level)
    if in_table
      value.to_s
    else
      I18n.t(key_for_unit(unit, medium), value: value)
    end
  end

  private_class_method def self.format_temperature(value)
    I18n.t(key_for_unit(:temperature), value: value.round(1))
  end

  private_class_method def self.format_date(value, format)
    date = value.is_a?(String) ? Date.parse(value) : value
    I18n.l(date, format: format)
  end

  private_class_method def self.format_percent(value, unit, user_numeric_comprehension_level, medium, unit_options)
    user_numeric_comprehension_level = :no_decimals if %i[percent_0dp relative_percent_0dp].include?(unit)

    value = value * 100.0 if unit_options.fetch(:scale, true)
    formatted_val = scale_num(value, false, user_numeric_comprehension_level)

    if %i[relative_percent relative_percent_0dp].include?(unit) && value > 0.0
      I18n.t(key_for_unit(unit, medium), sign: '+', value: formatted_val)
    else
      I18n.t(key_for_unit(unit, medium), sign: '', value: formatted_val)
    end
  end

  # 1.234 => +1,230%, 0.105 => +10%, 0.095 => +9.5%, 0.005 => +0.5%, 0.0005 => +0.0%
  private_class_method def self.format_comparison_percent(value, medium)
    percent = value * 100.0

    pct_str = if !percent.infinite?.nil?
                plus_minus_infinity_value(percent)
              elsif percent.round(1).zero?
                '0.0'
              elsif percent.magnitude < 10.0 #true for negative, up to value 0.1
                sprintf('%+.1f', percent)
              elsif percent.magnitude < 150.0 #true for up to value 1.5
                sprintf('%+.0f', percent)
              else
                "+#{scale_num(percent)}"
              end

    I18n.t(key_for_unit(:percent, medium), value: pct_str)
  end

  private_class_method def self.format_years_range(range)
    if range.first == range.last
      format_time(range.first)
    else
      I18n.t(key_for_unit(:years_range),
        low: format_time(range.first),
        high: format_time(range.last))
    end
  end

  private_class_method def self.format_pound_range(range, medium, user_numeric_comprehension_level)
    if ((range.last - range.first) / range.last).magnitude < 0.05 ||
      (range.first.magnitude < 0.005 && range.last.magnitude < 0.005)
      format_pounds(:£,range.first, medium, user_numeric_comprehension_level)
    else
      I18n.t(key_for_unit(:£_range, medium),
        low: format_pounds(:£,range.first, medium, user_numeric_comprehension_level),
        high: format_pounds(:£,range.last, medium, user_numeric_comprehension_level))
    end
  end

  def self.format_pounds(unit, value, medium, user_numeric_comprehension_level, no_dp = false)
    user_numeric_comprehension_level = :no_decimals if no_dp
    if (value.respond_to?(:nan?) && value.nan?) || (value.respond_to?(:infinite?) && value.infinite?)
      scale_num(value)
    elsif value.magnitude >= 1.0
      # £-40.00 => -£40.00
      I18n.t(key_for_unit(unit, medium), sign: (value < 0.0 ? '-' : ''), value: scale_num(value.magnitude, true, user_numeric_comprehension_level))
    else
      u = unit == :£_per_kwh ? :p_per_kwh : :p
      I18n.t(key_for_unit(u, medium), value: scale_num(value * 100.0, true, user_numeric_comprehension_level))
    end
  end

  def self.format_time(years)
    if years < (1.0 / 365.0) && years > 0.0 # less than a day
      minutes = 24 * 60 * 365.0 * years
      if minutes < 90
        I18n.t(MINUTES, count: minutes.round(0).to_s)
      else
        I18n.t(HOURS, count: (minutes / 60.0).round(0).to_s)
      end
    elsif years < (3.0 / 12.0) # less than 3 months
      days = (years * 365.0).round(0)
      if days <= 14
        I18n.t(DAYS, count: days.to_s)
      else
        I18n.t(WEEKS, count: (days / 7.0).round(0).to_s)
      end
    elsif years <= 1.51
      I18n.t(MONTHS, count: months_from_years(years))
    elsif years < 5.0
      y = years.floor
      I18n.t(YEARS, count: y) + " " +
      I18n.t(MONTHS, count: months_from_years(years - y))
    else
      I18n.t(YEARS, count: sprintf('%.0f', years))
    end
  end

  private_class_method def self.months_from_years(years)
    (years * 12.0).round(0)
  end

  private_class_method def self.format_days(days)
    I18n.t(DAYS, count: days.to_i)
  end

  private_class_method def self.key_for_unit(unit, medium = :text)
    default_key = "#{ENERGY_UNITS}.#{unit}".freeze
    if medium == :text
      default_key
    else
      html_key = html_key_for(unit)
      I18n.t(ENERGY_UNITS).key?(html_key) ? "#{ENERGY_UNITS}.#{html_key}".freeze : default_key
    end
  end

  private_class_method def self.html_key_for(unit)
    "#{unit}_html".to_sym
  end

  def self.known_unit?(unit)
    #originally used a hash of units (symbol) => unit label
    #now validate using the translation keys. This achieves same
    #goal whilst also ensuring we have added the unit to common.yml
    I18n.t(ENERGY_UNITS).key?(unit)
  end

  private_class_method def self.check_units(unit)
    unless known_unit?(unit)
      raise EnergySparksUnexpectedStateException.new("Unexpected unit #{unit}")
    end
  end

  private_class_method def self.plus_minus_infinity_value(value)
    if value == Float::INFINITY
      I18n.t(INFINITY)
    elsif value == -Float::INFINITY
      I18n.t(NEGATIVE_INFINITY)
    else
      raise InternalErrorNonInfiniteValue, "Bad value #{value}"
    end
  end

  def self.scale_num(value, in_pounds = false, user_numeric_comprehension_level = :ks2)
    return plus_minus_infinity_value(value) unless value.infinite?.nil?
    return I18n.t(NAN) if value.is_a?(Float) && value.nan?
    number = significant_figures_user_type(value, user_numeric_comprehension_level)
    return ZERO if number.zero?
    number_as_string = number.to_s
    before_decimal_point = number_as_string.gsub(/^(.*)\..*$/, '\1')
    # for some reason a number without dp e.g. 15042 when mathed with gsub(/.*(\..*)/, '\1') returns 15042 and not null as it should match ./?
    after_decimal_point = number_as_string.include?('.') ? number_as_string.gsub!(/.*(\..*)/, '\1').gsub(/^.*\.0$/, '') : ''
    if in_pounds && !after_decimal_point.empty? && after_decimal_point.length < 3
      # add zero pence onto e.g. £23.1 so it becomes £23.10
      after_decimal_point += ZERO
    elsif number.magnitude >= 1000
      return I18n.t(INFINITY) unless number.infinite?.nil?
      return number.round(0).to_s.reverse!.gsub(/(\d{3})(?=\d)/, '\\1,').reverse! + after_decimal_point
    end
    before_decimal_point + after_decimal_point
  end

  private_class_method def self.user_numeric_comprehension_level(user_type)
    case user_type
      # :no_decimals and :to_pence are also valid, but dealt with outwith the significant figures handling
    when :ks2
      2
    when :benchmark, :target
      3
    when :approx_accountant
      4
    when :accountant, :energy_expert
      10
    else
      raise EnergySparksUnexpectedStateException.new('Unexpected nil user_type for user_numeric_comprehension_level') if user_type.nil?
      raise EnergySparksUnexpectedStateException.new("Unexpected nil user_type #{user_type} for user_numeric_comprehension_level") if user_type.nil?
    end
  end

  private_class_method def self.no_recent_or_not_enough_data?(value)
    [
      ManagementSummaryTable::NO_RECENT_DATA_MESSAGE,
      ManagementSummaryTable::NOT_ENOUGH_DATA_MESSAGE
    ].include?(value)
  end

  private_class_method def self.significant_figures_user_type(value, user_numeric_comprehension_level)
    return value.round(0) if user_numeric_comprehension_level == :no_decimals
    return value.round(2) if user_numeric_comprehension_level == :to_pence
    significant_figures(value, user_numeric_comprehension_level(user_numeric_comprehension_level))
  end

  private_class_method def self.significant_figures(value, significant_figures)
    return 0 if value.nil? || value.zero?
    BigDecimal(value, significant_figures).to_f # value.round(-(Math.log10(value).ceil - significant_figures))
  end
end

# eventually migrate from FormatEnergyUnit to more generic FormatUnit
class FormatUnit < FormatEnergyUnit
end
