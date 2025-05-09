# frozen_string_literal: true

require_relative '../periods'

module Periods
  class FixedAcademicYear < YearPeriods
    protected

    def period_list(first_meter_date = @first_meter_date, last_meter_date = @last_meter_date)
      return [] if first_meter_date.nil? || last_meter_date.nil?

      self.class.enumerator(first_meter_date, last_meter_date).map { |args| new_school_period(*args) }
    end

    def self.enumerator(start_date, end_date)
      Enumerator.new do |enumerator|
        period_end = end_date
        while period_end >= start_date
          period_start = Date.new(period_end.year - (period_end.month < 9 ? 1 : 0), 9, 1)
          if period_start <= start_date
            enumerator.yield [start_date, period_end]
            break
          else
            enumerator.yield [period_start, period_end]
            period_end = period_start - 1
          end
        end
      end
    end

    def calculate_period_from_date(_date)
      raise EnergySparksUnsupportedFunctionalityException, 'not implemented yet'
    end
  end
end
