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
end
