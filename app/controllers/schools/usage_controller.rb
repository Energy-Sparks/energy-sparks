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

      @supply = validate_supply
      @period = validate_period
      @split_meters = params[:split_meters].present? || params[:mpxn].present?
      @show_measurements = @period == :weekly

      if @supply && @period && @school.send(:"has_#{@supply}?")
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
          earliest_reading: aggregate_school.aggregate_meter(:electricity).amr_data.start_date,
          last_reading: aggregate_school.aggregate_meter(:electricity).amr_data.end_date
        }
      elsif supply == :gas
        {
          weekly: :calendar_picker_gas_week_example_comparison_chart,
          daily: :calendar_picker_gas_day_example_comparison_chart,
          earliest_reading: aggregate_school.aggregate_meter(:gas).amr_data.start_date,
          last_reading: aggregate_school.aggregate_meter(:gas).amr_data.end_date
        }
      end
    end

    def setup_meters(school, supply)
      return Meter.none unless [:electricity, :gas].include?(supply)
      school.filterable_meters(supply)
    end

    def title_key(supply, period, split_meters)
      "charts.usage.titles.#{supply}.#{period}.#{split_meters ? 'split' : 'not_split'}"
    end

    def validate_period
      period = params.require(:period).to_sym
      if %i[weekly daily].include?(period)
        period
      else
        Rails.logger.error("Period #{period} not valid")
        nil
      end
    end

    def validate_supply
      supply = params.require(:supply).to_sym
      if %i[electricity gas].include?(supply)
        supply
      else
        Rails.logger.error("Supply #{supply} not valid")
        nil
      end
    end
  end
end
