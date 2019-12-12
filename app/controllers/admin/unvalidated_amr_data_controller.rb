module Admin
  class UnvalidatedAmrDataController < AdminController
    load_and_authorize_resource :school

    def show
      data = Amr::AnalyticsMeterCollectionFactory.new(@school).unvalidated_data

      respond_to do |format|
        format.yaml { send_data YAML.dump(data), filename: "unvalidated-data-#{@school.name.parameterize}.yaml" }
      end
    end
  end
end
