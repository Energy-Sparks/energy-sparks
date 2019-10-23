module Admin
  class EquivalencesController < AdminController
    def create
      school = School.find(params[:school_id])
      Equivalences::GenerateEquivalences.new(school, EnergyConversions).perform
      redirect_back fallback_location: admin_equivalence_types_path
    end
  end
end
