module Alerts
  module System
    class MissingData
      MISSING_CUTOFF_DAYS = 14

      def initialize(aggregated_meters:, alert_type:, today: Time.zone.today)
        @aggregated_meters = aggregated_meters
        @today = today
        @alert_type = alert_type
      end

      def report
        return empty_meters_report unless @aggregated_meters
        return late_running_meters_report if late_running_meters?

        meters_report
      end

      private

      def meters_report
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

      def rating
        cutoff_minus_10_days = (cutoff - 10.days)
        (@aggregated_meters.amr_data.end_date - cutoff_minus_10_days).to_f
      end

      def late_running_meters_report
        Adapters::Report.new(
          valid: true,
          rating: [0.0, rating].max,
          enough_data: :enough,
          relevance: :relevant,
          template_data: {
            mpan_mprns: mpan_mprns
          },
          template_data_cy: {
            mpan_mprns: mpan_mprns(locale: :cy)
          },
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

      def late_running_meters?
        @aggregated_meters.amr_data.end_date < cutoff
      end

      def cutoff
        @cutoff ||= @today - MISSING_CUTOFF_DAYS.days
      end

      def mpan_mprns(locale: :en)
        I18n.with_locale(locale) { @aggregated_meters.meter_list.to_sentence }
      end
    end
  end
end
