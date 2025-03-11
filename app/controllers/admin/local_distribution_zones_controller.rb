# frozen_string_literal: true

module Admin
  class LocalDistributionZonesController < AdminController
    include Columns
    load_and_authorize_resource
    def index
      respond_to do |format|
        format.html
        format.csv { send_csv }
      end
    end

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

    def send_csv
      columns = [
        Column.new(:zone_name,
                   ->(reading) { reading.local_distribution_zone.name }),
        Column.new(:zone_code,
                   ->(reading) { reading.local_distribution_zone.code }),
        Column.new('Zone Publication ID',
                   ->(reading) { reading.local_distribution_zone.publication_id }),
        Column.new(:date,
                   ->(reading) { reading.date }),
        Column.new(:calorific_value,
                   ->(reading) { reading.calorific_value })
      ]
      send_data csv_report(columns, LocalDistributionZoneReading.by_date.order(:local_distribution_zone_id)),
                filename: EnergySparks::Filenames.csv('LDZ-readings-report')
    end
  end
end
