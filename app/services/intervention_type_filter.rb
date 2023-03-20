class InterventionTypeFilter
  attr_reader :query

  def initialize(query: {}, school:, scope: nil, current_date: Time.zone.today)
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

private

  def exclude_if_done_this_year
    @query[:exclude_if_done_this_year]
  end

  def default_scope
    InterventionType.active.custom_last
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
