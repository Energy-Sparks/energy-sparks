# frozen_string_literal: true

class NextActivitySuggesterWithFilter
  NUMBER_OF_SUGGESTIONS = 5

  def initialize(school, filter)
    @school = school
    @filter = filter
    @suggestions = []
    @first_activity = @school.activities.empty?
  end

  def suggest
    if @first_activity
      get_initial_suggestions
    else
      get_suggestions_based_on_last_activity
    end

    # ensure minimum of five suggestions
    top_up_if_not_enough_suggestions if @suggestions.length < NUMBER_OF_SUGGESTIONS

    @suggestions
  end

  private

  def get_initial_suggestions
    ActivityTypeSuggestion.initial.order(:id).each do |ats|
      @suggestions << ats.suggested_type if suggestion_can_be_added?(ats.suggested_type)
    end
  end

  def get_suggestions_based_on_last_activity
    last_activity_type = @school.activities.order(:created_at).last.activity_type
    activity_type_filter = ActivityTypeFilter.new(query: @filter.query.merge(not_completed_or_repeatable: true), school: @school, scope: last_activity_type.suggested_types)
    activity_type_filter.activity_types.each do |suggested_type|
      @suggestions << suggested_type if suggestion_can_be_added?(suggested_type)
    end
  end

  def top_up_if_not_enough_suggestions
    more = @filter.activity_types.random_suggestions.sample(NUMBER_OF_SUGGESTIONS - @suggestions.length)
    @suggestions += more.select {|suggestion| suggestion_can_be_added?(suggestion)}
  end

  def suggestion_can_be_added?(suggested_type)
    @filter.activity_types.include?(suggested_type) && !@suggestions.include?(suggested_type)
  end
end
