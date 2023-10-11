module ActivityTypeFilterable
  extend ActiveSupport::Concern

  private

  def activity_type_filter_query
    permitted = params.permit(
      key_stage: { key_stage_ids: [] },
      subject: { subject_ids: [] },
      topic: { topic_ids: [] },
      activity_timing: { activity_timing_ids: [] },
      impact: { impact_ids: [] }
    )
    hash_of_id_parameters = permitted.values.inject({}, &:update)
    without_blanks = hash_of_id_parameters.map { |key, values| [key, values.reject(&:blank?)] }
    HashWithIndifferentAccess[without_blanks]
  end

  def activity_type_filter
    school = @school || (current_user ? current_user.school : nil)
    ActivityTypeFilter.new(query: activity_type_filter_query, school: school)
  end
end
