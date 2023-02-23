module Schools
  module Advice
    class ElectricityCostsController < AdviceBaseController
      protect_from_forgery except: :meter_costs

      def insights
      end

      def analysis
        @meters = @school.meters.active.electricity
        @multiple_meters = @school.meters.active.electricity.count > 1
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
    end
  end
end
