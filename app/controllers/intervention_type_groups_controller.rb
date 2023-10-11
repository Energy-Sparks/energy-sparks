class InterventionTypeGroupsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @suggested_interventions = load_suggested_interventions(current_user_school) if current_user_school
    @intervention_type_groups = @intervention_type_groups.by_name
  end

  def show; end

  def recommended
    @suggested_interventions = load_suggested_interventions(current_user.school)
  end

  private

  def load_suggested_interventions(school)
    Interventions::SuggestAction.new(school).suggest(20)
  end
end
