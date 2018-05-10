class NextActivitySuggester
  def initialize(school, first_activity = false)
    @school = school
    @suggestions = []
    @first_activity = first_activity
  end

  def suggest
    if @first_activity
      ActivityTypeSuggestion.initial.order(:id).each do |ats|
        @suggestions << ats.suggested_type
      end
    else
      last_activity_type = @school.activities.order(:created_at).last.activity_type
      last_activity_type.activity_type_suggestions.each do |ats|
        @suggestions << ats.suggested_type unless @school.activities.exists?(activity_type: ats.suggested_type)
      end
    end
    #ensure minimum of five suggestions
    if @suggestions.length < 5
      more = ActivityType.where(active: true, custom: false, data_driven: true, repeatable: true).sample(5 - @suggestions.length)
      @suggestions = @suggestions + more
    end
    @suggestions
  end
end
