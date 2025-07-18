# frozen_string_literal: true

class AggregatorMultiSchoolsPeriods
  module CalculateXAxis
    MONTHS = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].freeze
    MONTHS_TO_I = MONTHS.each_with_index.to_h { |month, index| [month, index] }

    def self.calculate(axis_months)
      axis_months.sort_by { |months| months.map { |month| MONTHS_TO_I[month] }.first }.flatten.uniq
      # max = (axis_months.map { |months| months.map { |n| (n - min) % 12 } }.map(&:last).max + min) % 12
      # # rotated.map { |n| (n - 9) % 12 }
      # [min..max].map { |i| MONTHS[i] }

      # last = all_months.map(&:last)
      # debugger
      # all_months
      # [all_months.map(&:first).min..all_months.map(&:last).max].map { |i| MONTHS[i] }
    end
  end
end
