require 'dashboard'

class Schools::ChartsController < ApplicationController
  before_action :set_school

  include SchoolAggregation
  include Measurements

  skip_before_action :authenticate_user!
  before_action :check_aggregated_school_in_cache

  def show
    respond_to do |format|
      format.html { render_html }
      format.json { render_json }
    end
  end

private

  def render_html
    @chart_type = params.require(:chart_type).to_sym
    set_measurement_options
    @measurement = measurement_unit(params[:measurement])
    @title = @chart_type.to_s.humanize
  end

  def render_json
    @chart_type ||= begin
                      params.require(:chart_type).to_sym
    rescue => error
                      render json: { error: error, status: 400 }.to_json and return
    end

    chart_config = {
      mpan_mprn: params[:mpan_mprn],
      series_breakdown: params[:series_breakdown],
      date_ranges: get_date_ranges
    }
    y_axis_units = params[:chart_y_axis_units]
    chart_config[:y_axis_units] = y_axis_units.to_sym if y_axis_units.present?
    provide_advice = params[:provide_advice] || false
    output = ChartData.new(
      @school,
      aggregate_school,
      @chart_type,
      chart_config,
      transformations: get_transformations,
      provide_advice: provide_advice,
      reraise_exception: true
    ).data

    if output
      render json: ChartDataValues.as_chart_json(output)
    else
      render json: {}
    end
  end

  def set_school
    @school = School.friendly.find(params[:school_id])
  end

  def get_transformations
    params.fetch(:transformations, {}).values.map do |(transformation_type, transformation_value)|
      [transformation_type.to_sym, transformation_value.to_i]
    end
  end

  def get_date_ranges
    params.fetch(:date_ranges) { {} }.values.map do |range|
      Date.parse(range['start'])..Date.parse(range['end'])
    end
  end
end
