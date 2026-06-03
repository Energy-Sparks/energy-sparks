module Schools
  class RecommendationsController < ApplicationController
    load_resource :school
    before_action :set_breadcrumbs
    before_action :set_scope

    skip_before_action :authenticate_user!, only: [:index]

    def index
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [
        { name: I18n.t('schools.recommendations.title') },
      ]
    end

    # will test this when it's actually used
    def set_scope
      @scope = valid_scope || scope_from_current_user
    end

    def valid_scope
      scope = params[:scope]
      scope if %w[pupil adult].include?(scope)
    end

    def scope_from_current_user
      current_user && (current_user.student_user? || current_user.staff?) ? 'pupil' : 'adult'
    end
  end
end
