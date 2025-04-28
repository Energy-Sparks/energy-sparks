module Schools
  module Advice
    class HotWaterController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        @gas_hot_water = gas_hot_water_model
      end

      def analysis
        @gas_hot_water = gas_hot_water_model
      end

      private

      def check_can_run_analysis
        @analysable = create_analysable
        render 'schools/advice/advice_base/not_enough_data' and return unless @analysable.enough_data?
        @has_swimming_pool = has_swimming_pool?
        render :not_relevant and return if not_relevant?
      end

      def not_relevant?
        has_swimming_pool? || minimal_use_of_gas?
      end

      def minimal_use_of_gas?
        gas_hot_water_model.investment_choices.existing_gas.efficiency > 1.0
      end

      def has_swimming_pool?
        @school.has_swimming_pool?
      end

      def create_analysable
        gas_hot_water_service
      end

      def gas_hot_water_model
        @gas_hot_water_model ||= gas_hot_water_service.create_model
      end

      def gas_hot_water_service
        @gas_hot_water_service ||= HotWater::GasHotWaterService.new(meter_collection: aggregate_school)
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html").html_safe
      end

      def advice_page_key
        :hot_water
      end
    end
  end
end
