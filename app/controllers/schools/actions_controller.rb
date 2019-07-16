# frozen_string_literal: true

module Schools
  class ActionsController < ApplicationController
    load_and_authorize_resource :school

    def new
      @intervention_type_groups = InterventionTypeGroup.includes(:intervention_types).references(:intervention_types).order('intervention_type_groups.title ASC, intervention_types.title ASC')
    end
  end
end
