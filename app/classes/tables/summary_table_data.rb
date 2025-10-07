module Tables
  class SummaryTableData
    def initialize(template_data)
      @template_data = template_data
    end

    # Used on group dashboard component
    def by_fuel_type_table
      fuel_type_table = {}
      fuel_types.map do |fuel_type|
        fuel_type_table[fuel_type] = OpenStruct.new(
          week: summary_data_for(fuel_type, :workweek),
          month: summary_data_for(fuel_type, :last_month),
          year: summary_data_for(fuel_type, :year)
        )
      end
      OpenStruct.new(fuel_type_table)
    end

    # Used on school dashboard component
    def by_fuel_type
      fuel_types.map do |fuel_type|
        [
          summary_data_for(fuel_type, :workweek),
          summary_data_for(fuel_type, :year)
        ]
      end.flatten
    end

    def date_ranges
      fuel_types.map do |fuel_type|
        "#{I18n.t("common.#{fuel_type}", default: fuel_type.to_s.humanize)} #{I18n.t('common.data')}: #{start_date(fuel_type)} - #{end_date(fuel_type)}."
      end.join(' ')
    end

    def table_date_ranges
      table_date_ranges = {}
      fuel_types.each do |fuel_type|
        table_date_ranges[fuel_type] = { start_date: start_date(fuel_type), end_date: end_date(fuel_type) }
      end
      table_date_ranges
    end

    def start_date(fuel_type)
      format_date(fetch(fuel_type, :start_date))
    end

    def end_date(fuel_type)
      format_date(fetch(fuel_type, :end_date))
    end

    def last_month(fuel_type)
      summary_data_for(fuel_type, :last_month)
    end

    def work_week(fuel_type)
      summary_data_for(fuel_type, :workweek)
    end

    def year(fuel_type)
      summary_data_for(fuel_type, :year)
    end

    private

    def fuel_types
      @template_data.blank? ? [] : @template_data.keys.sort
    end

    def summary_data_for(fuel_type, period)
      OpenStruct.new(
        period_key: period,
        fuel_type: fuel_type,
        period: format_period(period),
        usage: format_number(fetch(fuel_type, period, :kwh), :kwh),
        usage_text: format_number(fetch(fuel_type, period, :kwh), Float, :text),
        co2: format_number(fetch(fuel_type, period, :co2), :kg),
        co2_text: format_number(fetch(fuel_type, period, :co2), Float, :text),
        cost: format_number(fetch(fuel_type, period, :gbp), :£),
        cost_text: format_number(fetch(fuel_type, period, :gbp), Float, :text),
        savings: format_number(fetch(fuel_type, period, :savings_gbp), :£),
        savings_text: format_number(fetch(fuel_type, period, :savings_gbp), Float, :text),
        change: format_number(fetch(fuel_type, period, :percent_change), :comparison_percent, :text),
        change_text: format_number(fetch(fuel_type, period, :percent_change), :comparison_percent, :text),
        message: data_validity_message(fuel_type, period),
        message_class: data_validity_class(fuel_type, period),
        has_data: has_data?(fuel_type, period),
        start_date: start_date(fuel_type),
        end_date: end_date(fuel_type)
      )
    end

    def has_data?(fuel_type, period)
      !no_recent_data?(fuel_type, period) && [:kwh, :co2, :gbp].any? { |item| fetch(fuel_type, period, item).present? }
    end

    def no_recent_data?(fuel_type, period)
      # Originally analytics was providing a string "no recent data" for :recent, but only if it wasn't recent
      # now it is a recent true/false flag.
      # so: check for boolean, nil
      value = fetch(fuel_type, period, :recent)
      return !value if value.in? [true, false]
      # otherwise its old structure
      value.present? && value == I18n.t('classes.tables.summary_table_data.no_recent_data')
    end

    def data_validity_message(fuel_type, period)
      message = fetch(fuel_type, period, :available_from)
      return format_availability_message(message) if message.present?
      value = fetch(fuel_type, period, :recent)
      return I18n.t('classes.tables.summary_table_data.no_recent_data') if value == false
      # otherwise its old structure
      return value if value.present?
    end

    def data_validity_class(fuel_type, period)
      value = fetch(fuel_type, period, :recent)
      return '' if value == true
      return 'old-data' if value == false
      # otherwise its old structure
      return 'old-data' if value.present?
    end

    def format_availability_message(message)
      # old style
      return message if message.start_with?('Data available')
      # now a date
      return I18n.t('classes.tables.summary_table_data.data_available_from', date: format_future_date(Date.parse(message)))
    end

    def format_future_date(date)
      date < 30.days.from_now ? I18n.l(date, format: '%a %d %b %Y') : I18n.l(date, format: '%b %Y')
    end

    def format_period(period)
      case period
      when :workweek
        I18n.t('classes.tables.summary_table_data.last_week')
      when :last_month
        I18n.t('classes.tables.summary_table_data.last_month')
      else
        I18n.t('classes.tables.summary_table_data.last_year')
      end
    end

    def format_date(value)
      if (date = Date.parse(value))
        I18n.l(date, format: '%-d %b %Y')
      end
    rescue
      value
    end

    def format_number(value, units, medium = :html)
      return '' if value.nil?
      if Float(value)
        FormatEnergyUnit.format(units, value.to_f, medium, false, true, :target).html_safe
      end
    rescue
      I18n.t("classes.tables.summary_table_data.#{value}", default: value)
    end

    def fetch(fuel_type, period, item = nil)
      if item && @template_data[fuel_type] && @template_data[fuel_type][period]
        @template_data[fuel_type][period][item]
      elsif @template_data[fuel_type]
        @template_data[fuel_type][period]
      end
    end
  end
end
