module Admin
  class ValidatedMeterCollectionsController < AdminController
    load_and_authorize_resource :school

    def show
      meter_collection = Amr::AnalyticsValidatedMeterCollectionFactory.new(@school).build

      respond_to do |format|
        format.yaml { send_data YAML.dump(meter_collection), filename: "validated-meter-collection-#{@school.name.parameterize}.yaml" }
      end
    end
  end
end
