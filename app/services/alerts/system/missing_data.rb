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
        return report_empty_meters if meters.empty?
        return report_late_running_meters_empty if late_running_meters.empty?

        report_meters
      end

      private

      # def aggregate_school
      #   @aggregate_school ||= AggregateSchoolService.new(@school).aggregate_school
      # end

      def report_meters
        Adapters::Report.new(
          valid: true,
          rating: [0.0, (meters.map(&:last_validated_reading).min - (cutoff - 10.days)).to_f].max,
          enough_data: :enough,
          relevance: :relevant,
          template_data: {
            mpan_mprns: mpan_mprns(meters)
          },
          template_data_cy: {
            mpan_mprns: mpan_mprns(meters, :cy)
          },
          priority_data: {
            time_of_year_relevance: 5.0
          }
        )
      end

      def report_late_running_meters_empty
        Adapters::Report.new(
          valid: true,
          rating: 10.0,
          enough_data: :enough,
          relevance: :relevant,
          priority_data: {
            time_of_year_relevance: 5.0
          }
        )
      end

      def report_empty_meters
        Adapters::Report.new(
          valid: true,
          rating: nil,
          relevance: :never_relevant,
          enough_data: :not_enough
        )
      end

      def meters
        @meters ||= @school.meters_with_validated_readings(@meter_type)
        # @meters ||= case @meter_type
        #             when :electricity then aggregate_school.aggregated_electricity_meters
        #             when :gas then aggregate_school.aggregated_heat_meters
        #             end
      end

      def late_running_meters
        @late_running_meters ||= meters.select { |meter| meter.last_validated_reading < cutoff }
      end

      def cutoff
        @cutoff ||= @today - MISSING_CUTOFF_DAYS.days
      end

      def mpan_mprns(meters, locale = :en)
        return meters.map(&:mpan_mprn).to_sentence if locale == :en

        I18n.with_locale(locale) { meters.map(&:mpan_mprn).to_sentence }
      end
    end
  end
end
