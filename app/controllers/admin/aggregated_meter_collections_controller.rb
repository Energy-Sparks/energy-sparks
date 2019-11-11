module Admin
  class AggregatedMeterCollectionsController < AdminController
    load_and_authorize_resource :school

    def show
      meter_collection = AggregateSchoolService.new(@school).aggregate_school

      respond_to do |format|
        format.yaml { send_data YAML.dump(meter_collection), filename: "aggregated-meter-collection-#{@school.name.parameterize}.yaml" }
      end
    end
  end
end
