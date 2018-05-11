class NextActivitySuggesterWithKeyStages
  NUMBER_OF_SUGGESTIONS = 5

  def initialize(school, key_stages_as_array_of_names = school.key_stage_list)
    @school = school
    @suggestions = []
    @first_activity = @school.activities.empty?
    @key_stages = key_stages_as_array_of_names
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
      @suggestions << ats.suggested_type if (ats.suggested_type.key_stage_list & @key_stages).any?
    end
  end

  def get_suggestions_based_on_last_activity
    last_activity_type = @school.activities.order(:created_at).last.activity_type

    last_activity_type.activity_type_suggestions.each do |ats|
      if ! @school.activities.exists?(activity_type: ats.suggested_type) && (ats.suggested_type.key_stage_list & @key_stages).any?
        @suggestions << ats.suggested_type# unless @school.activities.exists?(activity_type: ats.suggested_type)
      end
    end
  end

  def top_up_if_not_enough_suggestions
    # pp "HEre  ActivityType.random_suggestions.count #{ActivityType.random_suggestions.count} "
    # pp "random tagged: ActivityType.random_suggestions.tagged_with(@key_stages, any: :true).count #{ActivityType.random_suggestions.tagged_with(@key_stages, any: :true).count}"
    # pp "suggestion count: #{@suggestions.count}"
    more = ActivityType.random_suggestions.tagged_with(@key_stages, any: :true).sample(NUMBER_OF_SUGGESTIONS - @suggestions.length)
    @suggestions += more
  end
end
