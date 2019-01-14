class ActivityTypeFilter
  def initialize(query, school: nil)
    @query = query
    @school = school
    @scope = ActivityType.includes(:key_stages, :subjects, :topics, :activity_timings, :impacts, :activity_category)
  end

  def activity_types
    [:key_stages, :subjects, :topics, :activity_timings, :impacts].inject(@scope) do |results, filter|
      selected = send(:"selected_#{filter}")
      selected.any? ? results.where(filter => { id: selected }) : results
    end
  end

  def for_category(category)
    activity_types.where(activity_category: category)
  end

  def selected_key_stages
    if @query[:key_stage_ids].present?
      KeyStage.where(id: @query[:key_stage_ids])
    elsif @school
      @school.key_stages
    else
      KeyStage.none
    end
  end

  def selected_subjects
    load_selected(Subject, :subject_ids)
  end

  def selected_topics
    load_selected(Topic, :topic_ids)
  end

  def selected_activity_timings
    load_selected(ActivityTiming, :activity_timing_ids)
  end

  def selected_impacts
    load_selected(Impact, :impact_ids)
  end

  def all_key_stages
    @all_key_stages ||= KeyStage.order(:name)
  end

  def all_subjects
    @all_subjects ||= Subject.order(:name)
  end

  def all_topics
    @all_topics ||= Topic.order(:name)
  end

  def all_activity_timings
    @all_activity_timings ||= ActivityTiming.order(:position)
  end

  def all_impacts
    @all_impacts ||= Impact.order(:name)
  end

private

  def load_selected(model, key)
    if @query[key].blank?
      model.none
    else
      model.where(id: @query[key])
    end
  end
end
