module Schools
  class CadsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school #, only: [:index, :create, :edit, :update]

    skip_before_action :authenticate_user!, only: [:live_data]

    def index
    end

    def new
    end

    def create
      if @cad.save
        redirect_to school_cads_path, notice: 'CAD was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @cad.update(cad_params)
        redirect_to school_cads_path, notice: 'CAD was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @cad.delete
      redirect_to school_cads_path, notice: 'CAD was successfully deleted.'
    end

    def live_data
      cad = @school.cads.find(params[:cad_id])
      value = data_service(cad).read
      render json: { type: :electricity, units: :watts, value: value }
    end

    private

    def data_service(cad)
      cad.test_mode ? Cads::SyntheticDataService.new(cad) : Cads::LiveDataService.new(cad)
    end

    def cad_params
      params.require(:cad).permit(:name, :device_identifier, :max_power, :test_mode, :active, :refresh_interval)
    end
  end
end
