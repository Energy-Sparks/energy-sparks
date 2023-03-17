module Schools
  module Advice
    class StorageHeatersController < AdviceBaseController
      before_action :set_seasonal_analysis, only: [:insights, :analysis]

      def insights
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def analysis_dates
        start_date = aggregate_school.storage_heater_meter.amr_data.start_date
        end_date = aggregate_school.storage_heater_meter.amr_data.end_date
        OpenStruct.new(
          start_date: start_date,
          end_date: end_date,
          one_year_before_end: end_date - 1.year,
          last_full_week_start_date: last_full_week_start_date(end_date),
          last_full_week_end_date: last_full_week_end_date(end_date),
          one_years_data: one_years_data?(start_date, end_date),
          months_of_data: months_between(start_date, end_date),
          recent_data: recent_data?(end_date)
        )
      end

      def set_seasonal_analysis
        @seasonal_analysis = build_seasonal_analysis
      end

      def build_seasonal_analysis
        Heating::SeasonalControlAnalysisService.new(meter_collection: aggregate_school, fuel_type: :storage_heater).seasonal_analysis
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html").html_safe
      end

      def advice_page_key
        :storage_heaters
      end
    end
  end
end
