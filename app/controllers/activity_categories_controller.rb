class ActivityCategoriesController < ApplicationController
  include ActivityTypeFilterable

  load_and_authorize_resource
  skip_before_action :authenticate_user!

  # GET /activity_categories
  def index
    @filter = activity_type_filter
    @activity_categories = @activity_categories.order(:name)
  end
end
