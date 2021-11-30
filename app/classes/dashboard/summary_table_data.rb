module Dashboard
  class SummaryTableData
    MONTH_YEAR_FORMAT = '%b %Y'.freeze

    def initialize(template_data)
      @template_data = template_data
    end

    def by_fuel_type
      fuel_types.map do |fuel_type|
        [summary_data_for(fuel_type, :year), summary_data_for(fuel_type, :workweek)]
      end.flatten
    end

    def date_ranges
      format_dates(@template_data)
    end

    private

    def fuel_types
      @template_data.keys
    end

    def summary_data_for(fuel_type, period)
      OpenStruct.new(
        fuel_type: fuel_type,
        period: format_period(period),
        usage: format_number(fetch(fuel_type, period, :kwh), :kwh),
        co2: format_number(fetch(fuel_type, period, :co2), :kg),
        cost: format_number(fetch(fuel_type, period, :£), :£),
        savings: format_number(fetch(fuel_type, period, :savings_£), :£),
        change: format_number(fetch(fuel_type, period, :percent_change), :relative_percent),
        message: data_validity_message(fuel_type, period),
        valid: data_valid?(fuel_type, period)
      )
    end

    def format_period(period)
      period == :workweek ? 'Last week' : 'Annual'
    end

    def data_valid?(fuel_type, period)
      !data_validity_message(fuel_type, period).present?
    end

    def data_validity_message(fuel_type, period)
      message = fetch(fuel_type, period, :recent)
      return message if message.present?
      message = fetch(fuel_type, period, :available_from)
      return message if message.present?
    end

    def format_dates(template_data)
      parts = []
      template_data.each do |fuel_type, data|
        parts << "#{fuel_type.to_s.humanize} data: #{format_date(data, :start_date)} - #{format_date(data, :end_date)}."
      end
      parts.join(' ')
    end

    def format_date(data, key)
      if (date = Date.parse(data[key]))
        date.strftime(MONTH_YEAR_FORMAT)
      end
    end

    def format_number(value, units)
      if Float(value)
        FormatEnergyUnit.format(units, value.to_f, :html, false, true, :target).html_safe
      end
    rescue
      value
    end
  end

  def fetch(fuel_type, period, item)
    @template_data[fuel_type][period][item] if @template_data[fuel_type] && @template_data[fuel_type][period]
  end
end
