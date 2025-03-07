# frozen_string_literal: true

module DateService
  def self.fixed_academic_year_end(date)
    Date.new(date.year + (date.month < 9 ? 0 : 1), 8, 31)
  end

  def self.subtitle_end_date(chart_type, date)
    if [:gas_by_month_acyear_0_1,
        :electricity_by_month_acyear_0_1,
        :electricity_cost_comparison_last_2_years_accounting].include?(chart_type)
      fixed_academic_year_end(date)
    else
      date
    end
  end
end
