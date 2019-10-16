module Schools
  class ActivityCategoriesController < ApplicationController
    include ActivityTypeFilterable

    load_and_authorize_resource :school

    def index
      @filter = activity_type_filter
      @activity_categories = ActivityCategory.all.includes(:activity_types).order(:name)
    end

    def show
    end
  end
end
