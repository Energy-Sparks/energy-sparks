require 'dashboard'

class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school, find_by: :slug
  skip_before_action :authenticate_user!
  before_action :set_school

  def index
    @results = []

    analysis_asof_date = Date.new(2018, 2, 2)
    AlertType.all.each do |alert_type|
      alert = alert_type.class_name.constantize.new(aggregate_school)
      alert.analyse(analysis_asof_date)
      @results << { report: alert.analysis_report, title: alert_type.title, description: alert_type.description }
    end
  end

private

  def set_school
    @school = School.find(params[:school_id])
  end

  def aggregate_school
    cache_key = "#{@school.name.parameterize}-aggregated_meter_collection"
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      meter_collection = MeterCollection.new(@school)
      AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
    end
  end
end
