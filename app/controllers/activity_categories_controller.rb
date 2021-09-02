class ActivityCategoriesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @pupil_categories = @activity_categories.pupil.by_name
    @activity_categories = @activity_categories.featured.by_name
    @activity_categories = @activity_categories.select { |activity_category| activity_category.activity_types.active.count > 4 }
  end
end
