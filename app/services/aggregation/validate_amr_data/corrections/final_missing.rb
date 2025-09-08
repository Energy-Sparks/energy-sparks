# frozen_string_literal: true

module Aggregation
  class ValidateAmrData
    module Corrections
      module FinalMissing
        # Finds any days with missing data, then replaces them with a fixed reading
        # values of 0.0123456 and a 'PROB' status code.
        #
        # Currently called at the end of validation to fill in any dates that haven't
        # been substituted by other methods. Would be dangerous to call at other stages
        #
        # Assume these are meant to be followed up, rather than treated as real
        # substituted data
        def self.correct(meter)
          amr_data = meter.amr_data
          missing_dates = (amr_data.start_date..amr_data.end_date).select { |date| amr_data.date_missing?(date) }
          missing_dates.each do |date|
            no_data = Array.new(48, 0.0123456)
            if %i[solar_pv exported_solar_pv].freeze.include?(meter.meter_type)
              Utilities::SunTimes.zero_night_hours(date, meter.meter_collection, no_data)
            end
            dummy_data = OneDayAMRReading.new(meter.mpan_mprn, date, 'PROB', nil, DateTime.now, no_data)
            amr_data.add(date, dummy_data)
          end
        end
      end
    end
  end
end
