require 'dashboard'

class Schools::ChartsController < ApplicationController
  include SchoolAggregation

  skip_before_action :authenticate_user!
  before_action :set_school

  def show
    chart_type = params[:chart_type].to_sym

    @charts = [chart_type]
    @title = chart_type.to_s.humanize
    @number_of_charts = 1

    this_aggregate_school = aggregate_school(@school)
    chart_manager = ChartManager.new(this_aggregate_school, current_user.try(:admin?))
    @output = [{ chart_type: chart_type, data: chart_manager.run_standard_chart(chart_type) }]

    respond_to do |format|
      format.json do
        render 'schools/charts/show'
      end
    end
  end

private

  def set_school
    @school = School.find_by_slug(params[:school_id])
  end
end
