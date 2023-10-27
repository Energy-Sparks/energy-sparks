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
        return empty_meters_report unless aggregated_meters
        return late_running_meters_empty_report if late_running_meters?

        meters_report
      end

      private

      def aggregate_school
        @aggregate_school ||= AggregateSchoolService.new(@school).aggregate_school
      end

      def meters_report
        Adapters::Report.new(
          valid: true,
          rating: [0.0, (aggregated_meters.amr_data.end_date - (cutoff - 10.days)).to_f].max,
          enough_data: :enough,
          relevance: :relevant,
          template_data: {
            mpan_mprns: mpan_mprns
          },
          template_data_cy: {
            mpan_mprns: mpan_mprns(:cy)
          },
          priority_data: {
            time_of_year_relevance: 5.0
          }
        )
      end

      def late_running_meters_empty_report
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

      def empty_meters_report
        Adapters::Report.new(
          valid: true,
          rating: nil,
          relevance: :never_relevant,
          enough_data: :not_enough
        )
      end

      def aggregated_meters
        @aggregated_meters ||= case @meter_type
                               when :electricity then aggregate_school.aggregated_electricity_meters
                               when :gas then aggregate_school.aggregated_heat_meters
                               end
      end

      def late_running_meters?
        aggregated_meters.amr_data.end_date < cutoff
      end

      def cutoff
        @cutoff ||= @today - MISSING_CUTOFF_DAYS.days
      end

      def mpan_mprns(locale = :en)
        return aggregated_meters.meter_list.to_sentence if locale == :en

        I18n.with_locale(locale) { aggregated_meters.meter_list.to_sentence }
      end
    end
  end
end
