# frozen_string_literal: true

module Meters
  class SummarisedCalendarGenerator < ReadingCalendarGenerator
    private

    def first_reading_date
      @meter.first_validated_reading
    end

    def summarise_readings
      readings = @meter.amr_validated_readings.order(:reading_date)
      reading_summary = readings.pluck(:reading_date, :status, :one_day_kwh).map do |reading_date, status, one_day_kwh|
        { reading_date => summary_hash(status, one_day_kwh) }
      end
      # Turn array of hashes in to a proper hash
      reading_summary.inject(:merge!)
    end

    def summary_hash(status, one_day_kwh)
      if one_day_kwh.zero?
        case status
        when 'ORIG'
          return { description: 'Zero usage, uncorrected original data', colour: '#5297c6' }
        when 'EST'
          return { description: 'Zero usage, original estimated data', colour: Colours.solar_dark }
        else
          return { description: 'Zero usage, corrected/modified data', colour: '#fcac21' }
        end
      end

      case status
      when 'ORIG'
        { description: 'ORIG, uncorrected good data', colour: Colours.chart_green }
      when 'EST'
        { description: 'EST, original estimated data', colour: Colours.solar_dark }
      else
        { description: 'Corrected/modified data', colour: '#3f7d69' }
      end
    end
  end
end
