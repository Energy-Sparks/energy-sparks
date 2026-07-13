
CSV.generate do |csv|
  csv << @headers
  @observations.each do |observation|
    csv << [
      observation.school.school_group&.name,
      observation.school.school_group&.default_issues_admin_user.name,
      observation.school.name,
      observation.created_by&.name,
      observation.created_by&.role&.humanize,
      observation.created_by&.staff_role&.title,
      observation.created_at.to_date.iso8601,
      observation.happened_on.to_date.iso8601,
      observation.intervention_type&.name,
      observation.description_includes_images?
    ]
  end
end.html_safe
