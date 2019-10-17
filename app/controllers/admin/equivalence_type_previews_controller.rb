module Admin
  class EquivalenceTypePreviewsController < AdminController
    def create
      school = School.find(params[:school_id])
      equivalence_type = EquivalenceType.new(equivalence_type_params)
      content = EquivalenceTypeContentVersion.new(content_params[:content])
      aggregate_school = AggregateSchoolService.new(school).aggregate_school
      @equivalence = Equivalences::Calculator.new(school, EnergyConversions.new(aggregate_school)).perform(equivalence_type, content)
      @equivalence_content = TemplateInterpolation.new(
        content,
        with_objects: { equivalence_type: equivalence_type }
      ).interpolate(
        :equivalence,
        with: @equivalence.formatted_variables
      )
      render 'show', layout: nil
    rescue Equivalences::Calculator::CalculationError => e
      render plain: "#{e.message} for #{school.name}"
    end

  private

    def equivalence_type_params
      params.require(:equivalence_type).permit(:meter_type, :time_period, :image_name)
    end

    def content_params
      params.require(:equivalence_type).permit(
        content: [:equivalence]
      )
    end
  end
end
