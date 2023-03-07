module Schools
  module Advice
    class ElectricityCostsController < AdviceBaseController
      protect_from_forgery except: :meter_costs

      def insights
      end

      def analysis
        @meters = @school.meters.active.electricity
        @multiple_meters = costs_service.multiple_meters?
        @complete_tariff_coverage = costs_service.complete_tariff_coverage?
        @periods_with_missing_tariffs = costs_service.periods_with_missing_tariffs
        @annual_costs = costs_service.annual_costs
        @analysis_dates = analysis_dates
      end

      def meter_costs
        @meter = @school.meters.find_by_mpan_mprn(params[:mpan_mprn])
        load_advice_page
        @analysis_dates = analysis_dates
        respond_to do |format|
          format.js
        end
      end

      private

      def advice_page_key
        :electricity_costs
      end

      def costs_service
        Schools::Advice::CostsService.new(@school, aggregate_school, :electricity)
      end
    end
  end
end
