module Schools
  class LiveDataController < ApplicationController
    load_resource :school

    skip_before_action :authenticate_user!
    before_action :redirect_if_disabled

    include AnalysisPages

    def show
      @suggestions = ActivityType.active.live_data.sample(5)
      @actions = Interventions::SuggestAction.new(@school).suggest
      @daily_variation_url = find_daily_variation_url(@school)
    end

    private

    def redirect_if_disabled
      redirect_to school_path(@school) unless EnergySparks::FeatureFlags.active?(:live_data)
    end

    def find_daily_variation_url(school)
      if find_analysis_page_of_class(school, 'AdviceElectricityIntraday')
        analysis_page_finder_path(urn: school.urn, analysis_class: 'AdviceElectricityIntraday')
      end
    end
  end
end
