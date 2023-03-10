module Schools
  module Advice
    class ElectricityCostsController < AdviceBaseController
      protect_from_forgery except: :meter_costs

      before_action :set_tariff_coverage, only: [:insights, :analysis]
      before_action :set_next_steps, only: [:insights]
      before_action :set_one_year_breakdown_chart, only: [:analysis, :meter_costs]

      def insights
        @annual_costs = costs_service.annual_costs
        @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months
        @change_in_costs = costs_service.calculate_change_in_costs
      end

      def analysis
        @meters = @school.meters.active.electricity
        @annual_costs = costs_service.annual_costs
        @multiple_meters = costs_service.multiple_meters?

        @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months
        @change_in_costs = costs_service.calculate_change_in_costs

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
          @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months
          @change_in_costs = costs_service.calculate_change_in_costs
        else
          meter = @school.meters.find_by_mpan_mprn(params[:mpan_mprn])
          @mpan_mprn = params[:mpan_mprn]
          @label = meter.name_or_mpan_mprn
          analytics_meter = costs_service.analytics_meter_for_mpan(@mpan_mprn)
          @monthly_costs = costs_service.calculate_costs_for_latest_twelve_months(analytics_meter)
          @change_in_costs = costs_service.calculate_change_in_costs(analytics_meter)
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
        @advice_page_insights_next_steps = @complete_tariff_coverage ? nil : I18n.t('advice_pages.electricity_costs.insights.next_steps_html', link: school_user_tariffs_path(@school)).html_safe
      end

      def set_one_year_breakdown_chart
        dates = analysis_dates
        days_of_data = dates.end_date - dates.start_date
        case days_of_data
        when 1..13
          @one_year_breakdown_chart = :electricity_cost_1_year_accounting_breakdown_group_by_day
          @one_year_breakdown_chart_key = :cost_1_year_accounting_breakdown_group_by_day
        when 14..79
          @one_year_breakdown_chart = :electricity_cost_1_year_accounting_breakdown_group_by_week
          @one_year_breakdown_chart_key = :cost_1_year_accounting_breakdown_group_by_week
        else
          @one_year_breakdown_chart = :electricity_cost_1_year_accounting_breakdown
          @one_year_breakdown_chart_key = :cost_1_year_accounting_breakdown
        end
      end

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

      def advice_page_fuel_type
        :electricity
      end

      def costs_service
        Schools::Advice::CostsService.new(@school, aggregate_school, :electricity)
      end
    end
  end
end
