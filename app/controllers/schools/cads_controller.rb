module Schools
  class CadsController < ApplicationController
    load_and_authorize_resource :school

    skip_before_action :authenticate_user!

    def live_data
      cad = @school.cads.find(params[:cad_id])
      value = data_service(cad).read
      render json: { type: :electricity, units: :watts, value: value }
    end

    private

    def data_service(cad)
      cad.test_mode ? Cads::SyntheticDataService.new(cad) : Cads::LiveDataService.new(cad)
    end
  end
end
