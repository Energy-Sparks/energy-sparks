module Schools
  module Advice
    class ElectricityCostsController < AdviceBaseController
      protect_from_forgery except: :meter_costs

      def insights
      end

      def analysis
        @meters = @school.meters.active.electricity
        @complete_tariff_coverage = costs_service.complete_tariff_coverage?
        @periods_with_missing_tariffs = costs_service.periods_with_missing_tariffs
        @annual_costs = costs_service.annual_costs
        @multiple_meters = costs_service.multiple_meters?
        if @multiple_meters
          @annual_costs_breakdown_by_meter = costs_service.annual_costs_breakdown_by_meter
          @aggregate_meter_adapter = aggregate_meter_adapter
          @options_for_meter_select = options_for_meter_select
        end
        @analysis_dates = analysis_dates
      end

      def meter_costs
        if params[:mpan_mprn] == aggregate_meter_mpan_mprn
          @mpan_mprn = aggregate_meter_mpan_mprn
          @label = aggregate_meter_label
        else
          meter = @school.meters.find_by_mpan_mprn(params[:mpan_mprn])
          @mpan_mprn = params[:mpan_mprn]
          @label = meter.name_or_mpan_mprn
        end
        load_advice_page
        @analysis_dates = analysis_dates
        respond_to do |format|
          format.js
        end
      end

      private

      def aggregate_meter_label
        I18n.t('advice_pages.electricity_costs.analysis.meter_breakdown.whole_school')
      end

      def aggregate_meter_mpan_mprn
        aggregate_school.aggregated_electricity_meters.mpan_mprn.to_s
      end

      def aggregate_meter_adapter
        OpenStruct.new(mpan_mprn: aggregate_meter_mpan_mprn, name_or_mpan_mprn: aggregate_meter_label)
      end

      def options_for_meter_select
        [aggregate_meter_adapter] + @meters.sort_by(&:name_or_mpan_mprn)
      end

      def advice_page_key
        :electricity_costs
      end

      def costs_service
        Schools::Advice::CostsService.new(@school, aggregate_school, :electricity)
      end
    end
  end
end
