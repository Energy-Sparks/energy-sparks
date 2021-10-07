module Schools
  class LiveDataController < ApplicationController
    include ActivityTypeFilterable

    load_resource :school

    skip_before_action :authenticate_user!
    before_action :redirect_if_disabled

    def show
      setup_activity_suggestions
      setup_actions
    end

    private

    def redirect_if_disabled
      redirect_to school_path(@school) unless EnergySparks::FeatureFlags.active?(:live_data)
    end

    def setup_activity_suggestions
      suggester = NextActivitySuggesterWithFilter.new(@school, activity_type_filter)
      @suggestions = suggester.suggest_for_school_targets
    end

    def setup_actions
      @actions = Interventions::SuggestAction.new(@school).suggest
    end
  end
end
