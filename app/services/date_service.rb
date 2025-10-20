# frozen_string_literal: true

module DateService
  def self.fixed_academic_year_end(date)
    Date.new(date.year + (date.month < 9 ? 0 : 1), 8, 31)
  end

  def self.subtitle_end_date(chart_config, date)
    if chart_config[:timescale].respond_to?(:dig) && chart_config.dig(:timescale, 0, :fixed_academic_year).present?
      fixed_academic_year_end(date)
    else
      date
    end
  end

  # Returns the first day of each month between two dates.
  #
  # @param start_date [Date, Time] the beginning date
  # @param end_date [Date, Time] the ending date
  # @return [Enumerator<Date>] an enumerator of month start dates
  # @example
  #   DateService.start_of_months(Date.new(2024, 1, 1), Date.new(2024, 3, 15)).map(&:to_s)
  #   # => ['2025-01-01', '2025-02-01', '2025-03-01']
  def self.start_of_months(start_date, end_date)
    Enumerator.new do |y|
      next if start_date >= end_date

      date = start_date.to_date.beginning_of_month
      while date <= end_date
        y << date
        date = date.next_month
      end
    end
  end
end
