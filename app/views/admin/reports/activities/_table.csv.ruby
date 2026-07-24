
CSV.generate do |csv|
  csv << @headers
  @activities.each do |activity|
    csv << [
      activity.school.school_group&.name,
      activity.school.school_group&.default_issues_admin_user.name,
      activity.school.name,
      activity.observation_user&.name,
      activity.observation_user&.role&.humanize,
      activity.observation_user&.staff_role&.title,
      activity.created_at.to_date.iso8601,
      activity.happened_on.to_date.iso8601,
      activity.display_title,
      activity.description_includes_images?
    ]
  end
end.html_safe
