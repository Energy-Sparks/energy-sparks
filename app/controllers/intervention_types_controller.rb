class InterventionTypesController < ApplicationController
  include Pagy::Method

  layout 'task', only: [:show]

  before_action :enable_bootstrap5, only: [:show]
  before_action :handle_head_request, only: [:show]

  load_and_authorize_resource
  before_action :set_breadcrumbs, only: [:show]

  skip_before_action :authenticate_user!, only: [:search, :show, :for_school]

  def search
    if params[:query]
      intervention_types = InterventionTypeSearchService.search(params[:query], I18n.locale)
      @pagy, @intervention_types = pagy(intervention_types)
    else
      @intervention_types = []
    end
  end

  def show
    if current_user_school
      @interventions = current_user_school.observations.includes(:intervention_type).intervention.where(intervention_type: @intervention_type).visible.by_date
    end
    @available_schools_for_user = current_user.schools(current_ability:) if current_user
  end

  def for_school
    school = School.find(params[:school_id])
    redirect_to new_school_intervention_path(school, intervention_type_id: @intervention_type.id)
  end

  private

  def set_breadcrumbs
    category = @intervention_type.category
    @breadcrumbs = [
      { name: t('common.labels.adult_actions'), href: intervention_type_groups_path },
      ({ name: category.name, href: intervention_type_group_path(category) } if category),
      { name: @intervention_type.name }
    ].compact
  end
end
