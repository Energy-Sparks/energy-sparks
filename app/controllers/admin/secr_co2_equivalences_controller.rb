# frozen_string_literal: true

module Admin
  class SecrCo2EquivalencesController < AdminController
    load_and_authorize_resource

    def new; end

    def edit; end

    def create
      if @secr_co2_equivalence.save
        redirect_to admin_secr_co2_equivalences_path, notice: "New #{SecrCo2Equivalence.model_name.human} created."
      else
        render :new
      end
    end

    def update
      if @secr_co2_equivalence.update(secr_co2_equivalences_params)
        redirect_to admin_secr_co2_equivalences_path, notice: "#{SecrCo2Equivalence.model_name.human} was updated."
      else
        render :edit
      end
    end

    private

    def secr_co2_equivalences_params
      permit_params(SecrCo2Equivalence)
    end
  end
end
