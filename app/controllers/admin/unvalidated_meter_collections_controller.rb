module Admin
  class UnvalidatedMeterCollectionsController < AdminController
    load_and_authorize_resource :school

    def show
      meter_collection = Amr::AnalyticsUnvalidatedMeterCollectionFactory.new(@school).build

      respond_to do |format|
        format.yaml { send_data YAML.dump(meter_collection), filename: "unvalidated-meter-collection-#{@school.name.parameterize}.yaml" }
      end
    end
  end
end
