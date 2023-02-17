module Schools
  module Advice
    class TotalEnergyUseController < AdviceBaseController
      def insights
        @overview_data = Schools::ManagementTableService.new(@school).management_data
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def advice_page_key
        :total_energy_use
      end

      def aggregate_meters
        [aggregate_school.aggregated_electricity_meters, aggregate_school.aggregated_heat_meters].compact
      end

      def analysis_start_date
        aggregate_meters.map { |meter| meter.amr_data.start_date }.max
      end

      def analysis_end_date
        aggregate_meters.map { |meter| meter.amr_data.end_date }.min
      end
    end
  end
end
