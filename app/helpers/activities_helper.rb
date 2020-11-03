module ActivitiesHelper
  def activity_categories_path_url(school)
    if school
      school_activity_categories_path(school)
    else
      activity_categories_path
    end
  end
end
