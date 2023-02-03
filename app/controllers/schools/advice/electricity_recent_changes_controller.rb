module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      include Measurements

      def insights
      end

      def analysis
        set_measurement_options
        @measurement = measurement_unit(params[:measurement])

        @supply = :electricity
        @period = get_period
        @split_meters = params[:split_meters].present?
        @show_measurements = @period == :weekly

        if @school.send("has_#{@supply}?")
          @meters = setup_meters(@school, @supply)
          @chart_config = setup_chart_config(@supply)
          @title_key = title_key(@supply, @period, @split_meters)
          # render :show
        else
          redirect_to school_path(@school), notice: 'No suitable supply could be found'
        end
      end

      private

      def setup_chart_config(_supply)
        {
          weekly: :calendar_picker_electricity_week_example_comparison_chart,
          daily: :calendar_picker_electricity_day_example_comparison_chart,
          earliest_reading:  aggregate_school.aggregate_meter(:electricity).amr_data.start_date,
          last_reading:  aggregate_school.aggregate_meter(:electricity).amr_data.end_date,
        }
      end

      def setup_meters(school, _supply)
        school.filterable_meters.electricity
      end

      def title_key(supply, period, split_meters)
        "charts.usage.titles.#{supply}.#{period}.#{split_meters ? 'split' : 'not_split'}"
      end

      def get_period
        return :weekly
        # period = params.require(:period).to_sym
        # raise ActionController::RoutingError, "Period #{period} not valid" unless [:weekly, :daily].include?(period)
        # period
      end

      def advice_page_key
        :electricity_recent_changes
      end
    end
  end
end
