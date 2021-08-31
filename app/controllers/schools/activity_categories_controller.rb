module Schools
  class ActivityCategoriesController < ::ActivityCategoriesController
    include ActivityTypeFilterable

    load_and_authorize_resource :school

    before_action :load_suggested_activities

    def recommended
    end

    def load_suggested_activities
      suggester = NextActivitySuggesterWithFilter.new(@school, activity_type_filter)
      @suggested_activities = suggester.suggest_for_school_targets(100)
    end
  end
end
