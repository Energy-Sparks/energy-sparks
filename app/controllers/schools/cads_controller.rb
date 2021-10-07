module Schools
  class CadsController < ApplicationController
    load_and_authorize_resource :school

    skip_before_action :authenticate_user!

    def live_data
      cad = @school.cads.find(params[:cad_id])
      service = Cads::LiveDataService.new(cad)
      value = service.read
      render json: { type: :electricity, units: :watts, value: value }
    end
  end
end
