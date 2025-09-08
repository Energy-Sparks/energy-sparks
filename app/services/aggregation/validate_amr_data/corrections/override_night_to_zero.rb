# frozen_string_literal: true

module Aggregation
  class ValidateAmrData
    module Corrections
      module OverrideNightToZero
        def self.apply(start_date, end_date, meter)
          start_date ||= meter.amr_data.start_date
          end_date ||= meter.amr_data.end_date
          (start_date..end_date).each do |date|
            next if meter.amr_data.date_missing?(date)

            data = meter.amr_data.one_days_data_x48(date)
            modified = Utilities::SunTimes.zero_night_hours(date, meter.meter_collection, data)
            if modified
              meter.amr_data.add(date, OneDayAMRReading.new(meter.mpan_mprn, date, 'SOLN', nil, DateTime.now, data))
            end
          end
        end
      end
    end
  end
end
