class NextActivitySuggester
  NUMBER_OF_SUGGESTIONS = 5

  def initialize(school, first_activity = false)
    @school = school
    @suggestions = []
    @first_activity = first_activity
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
      @suggestions << ats.suggested_type
    end
  end

  def get_suggestions_based_on_last_activity
    last_activity_type = @school.activities.order(:created_at).last.activity_type

    last_activity_type.activity_type_suggestions.each do |ats|
      @suggestions << ats.suggested_type unless @school.activities.exists?(activity_type: ats.suggested_type)
    end
  end

  def top_up_if_not_enough_suggestions
    more = ActivityType.where(active: true, custom: false, data_driven: true, repeatable: true).sample(5 - @suggestions.length)
    @suggestions += more
  end
end
