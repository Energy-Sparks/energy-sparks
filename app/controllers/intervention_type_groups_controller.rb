class InterventionTypeGroupsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @intervention_type_groups = @intervention_type_groups.by_title
  end

  def show
  end
end
