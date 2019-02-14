require 'dashboard'

class Schools::ChartsController < ApplicationController
  include SchoolAggregation
  include Measurements

  skip_before_action :authenticate_user!
  before_action :set_school

  def show
    @chart_type = params[:chart_type].to_sym
    y_axis_units = params[:chart_y_axis_units].to_sym if params[:chart_y_axis_units]

    respond_to do |format|
      format.html do
        set_measurement_options
        @measurement = measurement_unit(params[:measurement])
        @title = @chart_type.to_s.humanize

        # Get this loaded and warm the cache before starting the chart rendering
        aggregate_school(@school)
      end
      format.json do
        @output = ChartData.new(aggregate_school(@school), @chart_type, show_benchmark_figures?, y_axis_units).data
      end
    end
  end

private

  def show_benchmark_figures?
    current_user.try(:admin?)
  end

  def set_school
    @school = School.find_by_slug(params[:school_id])
  end
end
