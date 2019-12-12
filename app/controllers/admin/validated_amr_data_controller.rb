module Admin
  class ValidatedAmrDataController < AdminController
    load_and_authorize_resource :school

    def show
      data = Amr::AnalyticsMeterCollectionFactory.new(@school).validated_data

      respond_to do |format|
        format.yaml { send_data YAML.dump(data), filename: "validated-data-#{@school.name.parameterize}.yaml" }
      end
    end
  end
end
