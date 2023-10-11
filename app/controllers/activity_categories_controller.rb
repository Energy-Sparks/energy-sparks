class ActivityCategoriesController < ApplicationController
  include ActivityTypeFilterable
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @suggested_activities = load_suggested_activities(current_user_school) if current_user_school
    @pupil_categories = ActivityCategory.pupil.by_name
    @activity_categories = ActivityCategory.featured.by_name.select { |activity_category| activity_category.activity_types.active.count >= 4 }
    @activity_count = ActivityType.active_and_not_custom.count
    @programme_types = ProgrammeType.featured
  end

  def show; end

  def recommended
    @suggested_activities = load_suggested_activities(current_user.school)
  end

  private

  def load_suggested_activities(school)
    NextActivitySuggesterWithFilter.new(school, activity_type_filter).suggest_for_school_targets(20)
  end
end
