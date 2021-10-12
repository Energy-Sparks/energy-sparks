class ActivityTypeFilter
  FILTERS = [:key_stages, :subjects, :topics, :activity_timings, :impacts].freeze

  attr_reader :query

  def initialize(query: {}, school: nil, scope: nil, current_date: Time.zone.today)
    @query = query
    @school = school
    @scope = (scope || default_scope).left_joins(*FILTERS).preload(:activity_category, *FILTERS).group('activity_types.id')
    @current_date = current_date
  end

  def activity_types
    filtered = FILTERS.inject(@scope) do |results, filter|
      selected = send(:"selected_#{filter}")
      selected.any? ? results.where(filter => { id: selected }) : results
    end
    filtered = exclude_completed_activities(filtered) if exclude_if_done_this_year
    filtered = exclude_live_data_activities(filtered) if exclude_live_data_activity_types
    filtered
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

  def exclude_if_done_this_year
    @school && @query[:exclude_if_done_this_year]
  end

  def selected_subjects
    load_selected(Subject, :subject_ids)
  end

  def selected_topics
    load_selected(Topic, :topic_ids)
  end

  def selected_activity_timings
    if @query[:activity_timing_ids].blank?
      ActivityTiming.none
    else
      checked = ActivityTiming.where(id: @query[:activity_timing_ids])
      (checked + checked.select(&:include_lower).map {|timing| ActivityTiming.where('position < ?', timing.position)}.flatten).uniq
    end
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

  def default_scope
    ActivityType.active.custom_last
  end

  def exclude_live_data_activity_types
    @school && !@school.has_live_data?
  end

  def exclude_completed_activities(filtered)
    academic_year = @school.academic_year_for(@current_date)
    if academic_year
      completed_activities = @school.activities.between(academic_year.start_date, academic_year.end_date)
      filtered = filtered.where.not(id: completed_activities.map(&:activity_type_id).uniq)
    end
    filtered
  end

  def exclude_live_data_activities(filtered)
    live_data_activities = ActivityType.active.live_data
    filtered.where.not(id: live_data_activities.map(&:id))
  end
end
