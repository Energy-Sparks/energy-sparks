module Schools
  class CadsController < ApplicationController
    load_and_authorize_resource :school

    skip_before_action :authenticate_user!

    def live_data
      # cad = @school.cads.find(params[:cad_id])
      render json: rand(100)
    end
  end
end
