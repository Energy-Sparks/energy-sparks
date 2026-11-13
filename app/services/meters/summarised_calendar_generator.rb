# frozen_string_literal: true

module Meters
  class SummarisedCalendarGenerator < ReadingCalendarGenerator
    LEGEND = {
      'ORIG' => { description: 'Original uncorrected good data (ORIG)', colour: Colours.chart_green },
      'EST' => { description: 'Original estimated data (EST)', colour: Colours.solar_dark },
      'OTHER' => { description: 'Corrected/modified data (not ORIG)', colour: '#3f7d69' },
      'ZERO_ORIG' => { description: 'Zero usage, uncorrected original data (ORIG)', colour: '#5297c6' },
      'ZERO_OTHER' => { description: 'Zero usage, corrected/modified data (not ORIG)', colour: '#fcac21' }
    }.freeze

    private

    def generate_legend
      LEGEND.to_h { |_k, v| [v[:colour], v[:description]] }
    end

    def first_reading_date
      @meter.first_validated_reading
    end

    def summarise_readings
      readings = @meter.amr_validated_readings.order(:reading_date)
      reading_summary = readings.pluck(:reading_date, :status,
                                       :one_day_kwh).map do |reading_date, status, one_day_kwh|
        { reading_date => summary_hash(status, one_day_kwh) }
      end
      # Turn array of hashes in to a proper hash
      reading_summary.inject(:merge!)
    end

    def summary_hash(status, one_day_kwh)
      if one_day_kwh.zero?
        case status
        when 'ORIG'
          return LEGEND['ZERO_ORIG']
        when 'EST'
          return LEGEND['ZERO_EST']
        end
      end

      case status
      when 'ORIG'
        LEGEND['ORIG']
      when 'EST'
        LEGEND['EST']
      else
        LEGEND['OTHER']
      end
    end
  end
end
