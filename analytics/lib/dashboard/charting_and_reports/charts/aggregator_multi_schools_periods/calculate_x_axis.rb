# frozen_string_literal: true

class AggregatorMultiSchoolsPeriods
  module CalculateXAxis
    MONTHS = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].freeze
    MONTHS_TO_I = MONTHS.each_with_index.to_h { |month, index| [month, index] }

    def self.calculate(axis_months)
      axis_months.sort_by { |months| months.map { |month| MONTHS_TO_I[month] }.first }.flatten.uniq
    end
  end
end
