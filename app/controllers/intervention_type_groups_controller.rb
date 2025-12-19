class InterventionTypeGroupsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @intervention_type_groups = @intervention_type_groups.by_name
    @programme_types = ProgrammeType.featured.with_task_type(InterventionType)
  end

  def show
  end

  def recommended
    # redirect to new page
    if current_user.try(:school)
      redirect_to school_recommendations_path(current_user.school, scope: :adult)
    else
      redirect_to intervention_type_groups_path
    end
  end
end
