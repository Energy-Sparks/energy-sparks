module Schools
  class RecommendationsController < ApplicationController
    load_resource :school
    before_action :set_breadcrumbs

    def index
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [
        { name: I18n.t('schools.recommendations.title') },
      ]
    end
  end
end
