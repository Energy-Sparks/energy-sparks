module SchoolAggregation
  extend ActiveSupport::Concern

private

  def check_aggregated_school_in_cache
    return unless show_data_enabled_features?
    unless aggregate_school_service.in_cache_or_cache_off? || request.xhr?
      @aggregation_path = school_aggregated_meter_collection_path(@school)
      render 'schools/aggregated_meter_collections/show'
    end
  end

  def show_data_enabled_features?
    if current_user && current_user.admin?
      params[:no_data] ? false : true
    else
      @school.data_enabled?
    end
  end

  def aggregate_school_service
    @aggregate_school_service ||= AggregateSchoolService.new(@school)
  end

  def aggregate_school
    @aggregate_school ||= aggregate_school_service.aggregate_school
  end
end
