module Schools
  class ActivityCategoriesController < ApplicationController
    include ActivityTypeFilterable

    load_and_authorize_resource :school

    # GET /activity_categories
    def index
      @filter = activity_type_filter
      @activity_categories = ActivityCategory.all.includes(:activity_types).order(:name)
    end

    # GET /activity_categories/1
    def show
    end
  end
end
