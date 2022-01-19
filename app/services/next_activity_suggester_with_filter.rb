class NextActivitySuggesterWithFilter
  NUMBER_OF_SUGGESTIONS = 6

  def initialize(school, filter)
    @school = school
    @filter = filter
  end

  def suggest_from_activity_history
    suggestions = []
    if @school.activities.empty?
      get_initial_suggestions(suggestions)
    else
      get_suggestions_based_on_last_activity(suggestions)
    end

    #ensure minimum of five suggestions
    top_up_if_not_enough_suggestions(suggestions) if suggestions.length < NUMBER_OF_SUGGESTIONS

    suggestions
  end

  def suggest_from_programmes
    school_programme_type_ids = @school.programmes.joins(:programme_type).active.started.pluck(:programme_type_id)
    scope = ActivityType.joins(:programme_types, :programme_type_activity_types).where(programme_types: { active: true, id: school_programme_type_ids }).order('programme_type_activity_types.position ASC').group('activity_types.id, programme_type_activity_types.position')

    activity_type_filter = ActivityTypeFilter.new(query: @filter.query.merge(exclude_if_done_this_year: true), school: @school, scope: scope)
    activity_type_filter.activity_types
  end

  def suggest_from_find_out_mores
    content = @school.latest_content
    if content
      scope = content.find_out_more_activity_types
      activity_type_filter = ActivityTypeFilter.new(query: @filter.query, school: @school, scope: scope)
      activity_type_filter.activity_types
    else
      ActivityType.none
    end
  end

  def suggest_from_audits
    suggestions = ActivityType.joins(:audit_activity_types, :audits).where(audits: { school: @school })
    academic_year = @school.academic_year_for(Time.zone.today)
    if academic_year
      completed_activities = @school.activities.between(academic_year.start_date, academic_year.end_date)
      suggestions = suggestions.where.not(id: completed_activities.map(&:activity_type_id).uniq)
    end
    suggestions.to_a
  end

  #For school targets page. Selecting activities based on an order of preference
  #filtering based on key stages, with a fallback to other activities
  def suggest_for_school_targets(limit = 5)
    suggestions = suggest_from_audits
    return suggestions.take(limit) unless suggestions.length < limit

    top_up_from_list(suggest_from_programmes.to_a, suggestions)
    return suggestions.take(limit) unless suggestions.length < limit

    top_up_from_list(suggest_from_find_out_mores, suggestions)
    return suggestions.take(limit) unless suggestions.length < limit

    top_up_from_list(suggest_from_activity_history, suggestions)
    suggestions.take(limit)
  end

private

  def get_initial_suggestions(suggestions)
    ActivityTypeSuggestion.initial.order(:id).each do |ats|
      suggestions << ats.suggested_type if suggestion_can_be_added?(ats.suggested_type, suggestions)
    end
  end

  def get_suggestions_based_on_last_activity(suggestions)
    last_activity_type = @school.activities.order(:created_at).last.activity_type
    activity_type_filter = ActivityTypeFilter.new(query: @filter.query.merge(exclude_if_done_this_year: true), school: @school, scope: last_activity_type.suggested_types)
    activity_type_filter.activity_types.each do |suggested_type|
      if suggestion_can_be_added?(suggested_type, suggestions)
        suggestions << suggested_type
      end
    end
  end

  def top_up_if_not_enough_suggestions(suggestions)
    more = @filter.activity_types.random_suggestions.sample(NUMBER_OF_SUGGESTIONS - suggestions.length)
    top_up_from_list(more, suggestions)
  end

  def top_up_from_list(more, suggestions)
    suggestions.concat(more.select {|suggestion| suggestion_can_be_added?(suggestion, suggestions)})
  end

  def suggestion_can_be_added?(suggested_type, suggestions)
    @filter.activity_types.include?(suggested_type) && !suggestions.include?(suggested_type)
  end
end
