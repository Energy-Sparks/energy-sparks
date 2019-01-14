module KeyStageFilterable
  extend ActiveSupport::Concern

private

  def activity_type_filter_query
    permitted = params.permit(
      key_stage: { key_stage_ids: [] },
      subject: { subject_ids: [] },
      topic: { topic_ids: [] },
      timing: { timing_ids: [] },
      impact: { impact_ids: [] }
    )
    HashWithIndifferentAccess[permitted.values.inject(&:update).to_h.map {|key, values| [key, values.reject(&:blank?)]}]
  end

  def activity_type_filter
    school = @school || (current_user ? current_user.school : nil)
    ActivityTypeFilter.new(activity_type_filter_query, school: school)
  end

  def key_stage_filter_params
    params.permit(key_stage: { key_stage_ids: [] })
  end

  def selected_key_stage_filters
    key_stage = key_stage_filter_params[:key_stage]

    if key_stage.nil?
      default_key_stage_filters
    else
      filters = key_stage[:key_stage_ids]
      KeyStage.where(id: filters)
    end
  end

  def default_key_stage_filters
    if @school
      @school.key_stages
    elsif current_user.nil? || current_user.school.nil?
      KeyStage.order(:name)
    else
      # Set for the school defaults
      current_user.school.key_stages
    end
  end
end
