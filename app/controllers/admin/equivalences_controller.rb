module Admin
  class EquivalencesController < AdminController
    def show
      school = School.find(params[:school_id])
      equivalence_type = EquivalenceType.new(equivalence_type_params)
      content = EquivalenceTypeContentVersion.new(content_params[:content])
      aggregate_school = AggregateSchoolService.new(school).aggregate_school
      equivalence = Equivalences::Calculator.new(school, EnergyConversions.new(aggregate_school)).perform(equivalence_type, content)
      @equivalence_content = TemplateInterpolation.new(
        content
      ).interpolate(
        :equivalence,
        with: equivalence.formatted_variables
      )
      render 'show', layout: nil
    rescue EnergySparksNotEnoughDataException, EnergySparksNoMeterDataAvailableForFuelType => e
      render text: "#{e.message} for #{school.name}"
    end

    def create
      school = School.find(params[:school_id])
      Equivalences::GenerateEquivalences.new(school, EnergyConversions).perform
      redirect_back fallback_location: admin_equivalence_types_path
    end

  private

    def equivalence_type_params
      params.require(:equivalence_type).permit(:meter_type, :time_period)
    end

    def content_params
      params.require(:equivalence_type).permit(
        content: [:equivalence]
      )
    end
  end
end
