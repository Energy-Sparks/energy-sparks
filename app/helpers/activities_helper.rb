module ActivitiesHelper
  def activity_categories_path_url(school)
    # might have school without id during onboarding
    school && school.id ? school_activity_categories_path(school) : activity_categories_path
  end

  def activity_category_path_url(school, activity_category)
    school ? school_activity_category_path(school, activity_category) : activity_category_path(activity_category)
  end

  def activity_type_path_url(school, activity_type)
    school ? school_activity_type_path(school, activity_type) : activity_type_path(activity_type)
  end
end
