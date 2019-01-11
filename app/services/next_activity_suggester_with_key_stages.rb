class NextActivitySuggesterWithKeyStages
  NUMBER_OF_SUGGESTIONS = 5

  def initialize(school, key_stages = school.key_stages)
    @school = school
    @suggestions = []
    @first_activity = @school.activities.empty?
    @key_stages = key_stages
  end

  def suggest
    if @first_activity
      get_initial_suggestions
    else
      get_suggestions_based_on_last_activity
    end

    #ensure minimum of five suggestions
    top_up_if_not_enough_suggestions if @suggestions.length < NUMBER_OF_SUGGESTIONS

    @suggestions
  end

private

  def get_initial_suggestions
    ActivityTypeSuggestion.initial.order(:id).each do |ats|
      # If suggested type has a key stage which is in the list, add it
      @suggestions << ats.suggested_type if this_suggested_list_is_appropriate_to_key_stages?(ats.suggested_type)
    end
  end

  def get_suggestions_based_on_last_activity
    last_activity_type = @school.activities.order(:created_at).last.activity_type

    last_activity_type.activity_type_suggestions.each do |ats|
      if this_activity_type_has_not_been_done_before_or_is_repeatable?(ats.suggested_type) && this_suggested_list_is_appropriate_to_key_stages?(ats.suggested_type)
        @suggestions << ats.suggested_type
      end
    end
  end

  def top_up_if_not_enough_suggestions
    more = ActivityType.random_suggestions.includes(:key_stages).where(key_stages: { id: @key_stages }).sample(NUMBER_OF_SUGGESTIONS - @suggestions.length)
    @suggestions += more
  end

  def this_activity_type_has_not_been_done_before_or_is_repeatable?(suggested_type)
    suggested_type.repeatable || @school.activities.where(activity_type: suggested_type).empty?
  end

  def this_suggested_list_is_appropriate_to_key_stages?(suggested_type)
    (suggested_type.key_stages & @key_stages).any?
  end
end
