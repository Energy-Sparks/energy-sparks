module EnergyTariffs
  class EnergyTariffFlatPricesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :energy_tariff

    def index
      if @energy_tariff.energy_tariff_prices.any?
        redirect_to edit_school_energy_tariff_energy_tariff_flat_price_path(@school, @energy_tariff, @energy_tariff.energy_tariff_prices.first)
      else
        redirect_to new_school_energy_tariff_energy_tariff_flat_price_path(@school, @energy_tariff)
      end
    end

    def new
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.build
    end

    def create
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.build(energy_tariff_price_params.merge(default_attributes))
      if @energy_tariff_price.save
        redirect_to school_energy_tariff_energy_tariff_charges_path(@school, @energy_tariff)
      else
        render :new
      end
    end

    def edit
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.find(params[:id])
    end

    def update
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.find(params[:id])
      if @energy_tariff_price.update(energy_tariff_price_params)
         redirect_to school_energy_tariff_energy_tariff_charges_path(@school, @energy_tariff)
      else
        render :edit
      end
    end

    private

    def default_attributes
      {
        units: 'kwh',
        start_time: Time.zone.parse('00:00'),
        end_time: Time.zone.parse('23:30')
      }
    end

    def energy_tariff_price_params
      params.require(:energy_tariff_price).permit(:value)
    end
  end
end
