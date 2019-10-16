class ActivityCategoriesController < ApplicationController
  include ActivityTypeFilterable

  # GET /activity_categories
  def index
    @filter = activity_type_filter
    @activity_categories = ActivityCategory.all.order(:name)
  end
end
