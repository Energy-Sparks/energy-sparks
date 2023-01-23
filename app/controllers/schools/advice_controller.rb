module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    before_action :load_advice_pages
    before_action :load_recommendations, only: [:insights]

    include SchoolAggregation

    def show
    end

    private

    def load_advice_pages
      @advice_pages = AdvicePage.all.by_key
    end

    def load_recommendations
      @activity_types = @advice_page.activity_types.limit(3)
      @intervention_types = @advice_page.intervention_types.limit(3)
    end
  end
end
