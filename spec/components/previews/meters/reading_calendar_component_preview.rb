# frozen_string_literal: true

module Meters
  class ReadingCalendarComponentPreview < ViewComponent::Preview
    def detailed
      meter = Meter.active.joins(:amr_validated_readings).distinct.sample
      render Meters::ReadingCalendarComponent.new(meter:,
                                                  calendar_generator: Meters::DetailedCalendarGenerator.new(meter),
                                                  path: admin_reports_amr_validated_reading_path(
                                                    meter, format: :json
                                                  ))
    end

    def summary
      meter = Meter.active.joins(:amr_validated_readings).distinct.sample
      render Meters::ReadingCalendarComponent.new(meter:,
                                                  calendar_generator: Meters::SummarisedCalendarGenerator.new(meter),
                                                  path: admin_reports_amr_validated_reading_summary_path(
                                                    meter, format: :json
                                                  ))
    end
  end
end
