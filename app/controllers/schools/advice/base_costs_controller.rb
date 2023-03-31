module Schools
  module Advice
    class BaseCostsController < AdviceBaseController
      protect_from_forgery except: :meter_costs

      before_action :set_tariff_coverage, only: [:insights, :analysis]
      before_action :set_next_steps, only: [:insights]
      before_action :set_one_year_breakdown_chart, only: [:analysis, :meter_costs]
      before_action :set_meters, only: [:analysis]

      def insights
        @annual_costs = costs_service.annual_costs
        @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months
        @change_in_costs = costs_service.calculate_change_in_costs
      end

      def analysis
        @annual_costs = costs_service.annual_costs
        @multiple_meters = costs_service.multiple_meters?
        @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months
        @change_in_costs = costs_service.calculate_change_in_costs
        @aggregate_meter_mpan_mprn = aggregate_meter_mpan_mprn
        if @multiple_meters
          @annual_costs_breakdown_by_meter = costs_service.annual_costs_breakdown_by_meter
          @aggregate_meter_adapter = aggregate_meter_adapter
          @options_for_meter_select = options_for_meter_select
        end
        @analysis_dates = analysis_dates
        @costs_service_analysis_date_range = costs_service.analysis_date_range
      end

      def meter_costs
        if params[:mpan_mprn] == aggregate_meter_mpan_mprn
          @mpan_mprn = aggregate_meter_mpan_mprn
          @label = aggregate_meter_label
          @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months
          @change_in_costs = costs_service.calculate_change_in_costs
        else
          meter = @school.meters.find_by_mpan_mprn(params[:mpan_mprn])
          @mpan_mprn = params[:mpan_mprn]
          @label = meter.name_or_mpan_mprn
          analytics_meter = costs_service.analytics_meter_for_mpan(@mpan_mprn)
          @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months(analytics_meter)
          @change_in_costs = costs_service.calculate_change_in_costs(analytics_meter)
          @tariffs = costs_service.tariffs(analytics_meter)
        end
        @analysis_dates = analysis_dates
        respond_to do |format|
          format.js
        end
      end

      private

      def set_tariff_coverage
        @complete_tariff_coverage = costs_service.complete_tariff_coverage?
        @periods_with_missing_tariffs = costs_service.periods_with_missing_tariffs
      end

      def set_next_steps
        @advice_page_insights_next_steps = @complete_tariff_coverage ? nil : I18n.t("advice_pages.#{advice_page_key}.insights.next_steps_html", link: school_user_tariffs_path(@school)).html_safe
      end

      def aggregate_meter_label
        I18n.t("advice_pages.#{advice_page_key}.analysis.meter_breakdown.whole_school")
      end

      def aggregate_meter_mpan_mprn
        aggregate_meter.mpan_mprn.to_s
      end

      def aggregate_meter_adapter
        OpenStruct.new(mpan_mprn: aggregate_meter_mpan_mprn, name_or_mpan_mprn: aggregate_meter_label)
      end

      def options_for_meter_select
        [aggregate_meter_adapter] + @meters.sort_by(&:name_or_mpan_mprn)
      end

      def costs_service
        Schools::Advice::CostsService.new(@school, aggregate_school, advice_page_fuel_type)
      end
    end
  end
end
