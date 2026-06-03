class ActivityCategoriesController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @pupil_categories = ActivityCategory.pupil.by_name
    @activity_categories = ActivityCategory.featured.by_name.select { |activity_category| activity_category.activity_types.active.count >= 4 }
    @activity_count = ActivityType.active_and_not_custom.count
    if Flipper.enabled?(:todos, current_user)
      @programme_types = ProgrammeType.featured.with_task_type(ActivityType)
    else
      @programme_types = ProgrammeType.featured
    end
  end

  def show
  end

  def recommended
    # redirect to new page
    if current_user.try(:school)
      redirect_to school_recommendations_path(current_user.school, scope: :pupil)
    else
      redirect_to activity_categories_path
    end
  end
end
