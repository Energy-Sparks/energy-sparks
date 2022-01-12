module Tables
  class SummaryTableData
    def initialize(template_data)
      @template_data = template_data
    end

    def by_fuel_type
      fuel_types.map do |fuel_type|
        [summary_data_for(fuel_type, :workweek), summary_data_for(fuel_type, :year)]
      end.flatten
    end

    def date_ranges
      fuel_types.map do |fuel_type|
        "#{fuel_type.to_s.humanize} data: #{format_date(fetch(fuel_type, :start_date))} - #{format_date(fetch(fuel_type, :end_date))}."
      end.join(' ')
    end

    private

    def fuel_types
      @template_data.blank? ? [] : @template_data.keys
    end

    def summary_data_for(fuel_type, period)
      OpenStruct.new(
        fuel_type: fuel_type,
        period: format_period(period),
        usage: format_number(fetch(fuel_type, period, :kwh), :kwh),
        co2: format_number(fetch(fuel_type, period, :co2), :kg),
        cost: format_number(fetch(fuel_type, period, :£), :£),
        savings: format_number(fetch(fuel_type, period, :savings_£), :£),
        change: format_number(fetch(fuel_type, period, :percent_change), :comparison_percent, :text),
        message: data_validity_message(fuel_type, period),
        message_class: data_validity_class(fuel_type, period),
        has_data: has_data?(fuel_type, period)
      )
    end

    def has_data?(fuel_type, period)
      !no_recent_data?(fuel_type, period) && [:kwh, :co2, :£].any? { |item| fetch(fuel_type, period, item).present? }
    end

    def no_recent_data?(fuel_type, period)
      #Originally analytics was providing a string "no recent data" for :recent, but only if it wasn't recent
      #now it is a recent true/false flag.
      #so: check for boolean, nil
      value = fetch(fuel_type, period, :recent)
      return !value if value.in? [true, false]
      #otherwise its old structure
      value.present? && value == "no recent data"
    end

    def data_validity_message(fuel_type, period)
      message = fetch(fuel_type, period, :available_from)
      return format_availability_message(message) if message.present?
      value = fetch(fuel_type, period, :recent)
      return "no recent data" if value == false
      #otherwise its old structure
      return value if value.present?
    end

    def data_validity_class(fuel_type, period)
      value = fetch(fuel_type, period, :recent)
      return 'old-data' if value == false
      #otherwise its old structure
      return 'old-data' if value.present?
    end

    def format_availability_message(message)
      #old style
      return message if message.start_with?("Data available")
      #now a date
      return "Data available from #{format_future_date(Date.parse(message))}"
    end

    def format_future_date(date)
      date < 30.days.from_now ? date.strftime('%a %d %b %Y') : date.strftime('%b %Y')
    end

    def format_period(period)
      period == :workweek ? 'Last week' : 'Last year'
    end

    def format_date(value)
      if (date = Date.parse(value))
        date.strftime("%-d %b %Y")
      end
    rescue
      value
    end

    def format_number(value, units, medium = :html)
      if Float(value)
        FormatEnergyUnit.format(units, value.to_f, medium, false, true, :target).html_safe
      end
    rescue
      value
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
