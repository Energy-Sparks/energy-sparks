class InterventionTypeFilter
  attr_reader :query

  def initialize(query: {}, school: nil, scope: nil, current_date: Time.zone.today)
    @query = query
    @school = school
    @scope = (scope || default_scope).preload(:intervention_type_group).group('intervention_types.id')
    @current_date = current_date
  end

  def intervention_types
    filtered = @scope
    filtered = exclude_completed_activities(filtered) if exclude_if_done_this_year
    filtered
  end

  def for_category(category)
    intervention_types.where(intervention_type_group: category)
  end

  def exclude_if_done_this_year
    @school && @query[:exclude_if_done_this_year]
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
    InterventionTypes.active.custom_last
  end

  def exclude_completed_activities(filtered)
    academic_year = @school.academic_year_for(@current_date)
    if academic_year
      completed_actions = @school.observations.intervention.between(academic_year.start_date, academic_year.end_date)
      filtered = filtered.where.not(id: completed_actions.map(&:intervention_type_id).uniq)
    end
    filtered
  end
end
