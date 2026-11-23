# frozen_string_literal: true

module Alerts
  class NonEstimatedMixin
    private

    def last_meter_date
      aggregate_meter.amr_data.end_date.downto(aggregate_meter.amr_data.start_date).find do |date|
        non_estimated_reading?(date)
      end
    end

    def non_estimated_reading?(date)
      reading = aggregate_meter.amr_data[date]
      !reading.nil? && reading.type != 'EST'
    end

    def non_estimated_days(count)
      aggregate_meter.amr_data.each_key.lazy.select { |date| non_estimated_reading?(date) }.take(count).count
    end
  end
end
