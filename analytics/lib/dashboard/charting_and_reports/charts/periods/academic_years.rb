# frozen_string_literal: true

require_relative '../periods'

module Periods
  class AcademicYears < YearPeriods
    protected

    def period_list(first_meter_date = @first_meter_date, last_meter_date = @last_meter_date)
      list = []
      period_end = last_meter_date
      while period_end > first_meter_date
        holiday = @meter_collection.holidays.find_summer_holiday_before(period_end)
        if holiday.nil? || holiday.start_date < first_meter_date
          list << [first_meter_date, period_end]
          break
        end
        list << [holiday.end_date + 1, period_end]
        period_end = holiday.end_date
      end
      list.map { |args| new_school_period(*args) }
    end

    def calculate_period_from_date(_date)
      raise EnergySparksUnsupportedFunctionalityException, 'not implemented yet'
    end
  end
end
