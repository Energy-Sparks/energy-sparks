module Schools
  class UsageController < ApplicationController
    include Measurements
    include SchoolAggregation

    load_and_authorize_resource :school

    skip_before_action :authenticate_user!, only: [:show]
    before_action :check_aggregated_school_in_cache, only: [:show]

    def show
      set_measurement_options
      @measurement = measurement_unit(params[:measurement])

      @supply = params.require(:supply).to_sym
      @period = get_period
      @split_meters = params[:split_meters].present?
      @show_measurements = @period == :weekly

      if @school.send("has_#{@supply}?")
        @meters = setup_meters(@school, @supply)
        @chart_config = setup_chart_config(@supply)
        @title_key = title_key(@supply, @period, @split_meters)
        render :show
      else
        redirect_to school_path(@school), notice: 'No suitable supply could be found'
      end
    end

    private

    def setup_chart_config(supply)
      if supply == :electricity
        {
          weekly: :calendar_picker_electricity_week_example_comparison_chart,
          daily: :calendar_picker_electricity_day_example_comparison_chart,
          earliest_reading:  aggregate_school.aggregate_meter(:electricity).amr_data.start_date,
          last_reading:  aggregate_school.aggregate_meter(:electricity).amr_data.end_date,
        }
      elsif supply == :gas
        {
          weekly: :calendar_picker_gas_week_example_comparison_chart,
          daily: :calendar_picker_gas_day_example_comparison_chart,
          earliest_reading:  aggregate_school.aggregate_meter(:gas).amr_data.start_date,
          last_reading:  aggregate_school.aggregate_meter(:gas).amr_data.end_date,
        }
      end
    end

    def setup_meters(school, supply)
      case supply
      when :electricity then school.filterable_meters.electricity
      when :gas then school.filterable_meters.gas
      else Meter.none
      end
    end

    def title_key(supply, period, split_meters)
      "charts.usage.titles.#{supply}.#{period}.#{split_meters ? 'split' : 'not_split'}"
    end

    def get_period
      period = params.require(:period).to_sym
      raise ActionController::RoutingError, "Period #{period} not valid" unless [:weekly, :daily].include?(period)
      period
    end
  end
end
