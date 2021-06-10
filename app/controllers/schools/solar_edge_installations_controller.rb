module Schools
  class SolarEdgeInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def solar_edge_installation_params
    params.require(:solar_edge_installation).permit(
      :site_id, :amr_data_feed_config_id, :mpan, :api_key
    )
  end
end
