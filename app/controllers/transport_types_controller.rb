class TransportTypesController < ApplicationController
  respond_to :json

  def index
    respond_with TransportType.select(:id, :name, :image, :kg_co2e_per_km, :speed_km_per_hour, :can_share, :park_and_stride).index_by(&:id)
  end
end
