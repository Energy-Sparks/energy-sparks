module Schools
  class LiveDataController < ApplicationController
    load_resource :school

    skip_before_action :authenticate_user!
    before_action :redirect_if_disabled

    def show
      @suggestions = ActivityType.active.live_data.sample(5)
      @actions = Interventions::SuggestAction.new(@school).suggest
    end

    private

    def redirect_if_disabled
      redirect_to school_path(@school) unless EnergySparks::FeatureFlags.active?(:live_data)
    end
  end
end
