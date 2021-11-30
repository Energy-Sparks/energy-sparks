module Dashboard
  class SummaryTableData
    MONTH_YEAR_FORMAT = '%b %Y'.freeze

    def initialize(template_data)
      @template_data = template_data
    end

    def by_fuel_type
      fuel_types.map do |fuel_type|
        summary_data_for(fuel_type, @template_data[fuel_type])
      end
    end

    def date_ranges
      format_dates(@template_data)
    end

    private

    def fuel_types
      @template_data.keys
    end

    def summary_data_for(fuel_type, data)
      OpenStruct.new(
        fuel_type: fuel_type,
        workweek_valid: data_valid?(data, :workweek),
        workweek_usage: format_number(fetch(data, :workweek, :kwh), :kwh),
        workweek_co2: format_number(fetch(data, :workweek, :co2), :kg),
        workweek_cost: format_number(fetch(data, :workweek, :£), :£),
        workweek_savings: format_number(fetch(data, :workweek, :savings_£), :£),
        workweek_change: format_number(fetch(data, :workweek, :percent_change), :relative_percent),
        workweek_message: data_validity_message(data, :workweek),
        annual_valid: data_valid?(data, :year),
        annual_usage: format_number(fetch(data, :year, :kwh), :kwh),
        annual_co2: format_number(fetch(data, :year, :co2), :kg),
        annual_cost: format_number(fetch(data, :year, :£), :£),
        annual_savings: format_number(fetch(data, :year, :savings_£), :£),
        annual_change: format_number(fetch(data, :year, :percent_change), :relative_percent),
        annual_message: data_validity_message(data, :year)
      )
    end

    def data_valid?(data, key)
      !data_validity_message(data, key).present?
    end

    def data_validity_message(data, key)
      return data[key][:recent] if fetch(data, key, :recent).present?
      return data[key][:available_from] if fetch(data, key, :available_from).present?
    end

    def fetch(data, period, item)
      data[period][item] if data[period]
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
      FormatEnergyUnit.format(units, value.to_f, :html, false, true, :target).html_safe
    end
  end
end
