module Alerts
  module System
    class MissingData
      MISSING_CUTOFF_DAYS = 14

      def initialize(school:, alert_type:, today: Time.zone.today, meter_type:)
        @school = school
        @today = today
        @alert_type = alert_type
        @meter_type = meter_type
      end

      def report
        meters = @school.meters_with_validated_readings(@meter_type)
        cutoff = @today - MISSING_CUTOFF_DAYS.days
        if meters.empty?
          Adapters::Report.new(
            valid: true,
            rating: nil,
            relevance: :never_relevant,
            enough_data: :not_enough
          )
        else
          late_running_meters = meters.select {|meter| meter.last_validated_reading < cutoff}
          if late_running_meters.empty?
            Adapters::Report.new(
              valid: true,
              rating: 10.0,
              enough_data: :enough,
              relevance: :relevant,
              priority_data: {
                time_of_year_relevance: 5.0
              }
            )
          else
            Adapters::Report.new(
              valid: true,
              rating: [0.0, (meters.map(&:last_validated_reading).min - (cutoff - 10.days)).to_f].max,
              enough_data: :enough,
              relevance: :relevant,
              template_data: {
                mpan_mprns: meters.map(&:mpan_mprn).to_sentence
              },
              priority_data: {
                time_of_year_relevance: 5.0
              }
            )
          end
        end
      end
    end
  end
end
