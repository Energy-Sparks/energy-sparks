# frozen_string_literal: true

module Admin
  class LocalDistributionZonesController < AdminController
    load_and_authorize_resource

    def new
    end

    def edit
    end

    def create
      if @local_distribution_zone.save
        redirect_to admin_local_distribution_zones_path, notice: 'New Local Distribution Zone created.'
      else
        render :new
      end
    end

    def update
      if @local_distribution_zone.update(local_distribution_zone_params)
        @local_distribution_zone.weather_observations.delete_all if lat_long_changed?
        redirect_to admin_local_distribution_zone_path, notice: 'Local Distribution Zone was updated.'
      else
        render :edit
      end
    end

    private

    def local_distribution_zone_params
      params.require(:local_distribution_zone).permit(:name, :code, :publication_id)
    end
  end
end
