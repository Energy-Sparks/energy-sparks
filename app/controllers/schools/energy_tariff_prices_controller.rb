module Schools
  class EnergyTariffPricesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :energy_tariff

    def index
      if @energy_tariff.flat_rate?
        redirect_to school_energy_tariff_energy_tariff_flat_prices_path(@school, @energy_tariff)
      else
        redirect_to school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
      end
    end

    def new
      if @energy_tariff.flat_rate?
        redirect_to new_school_energy_tariff_energy_tariff_flat_prices_path(@school, @energy_tariff)
      else
        redirect_to new_school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
      end
    end

    def edit
      if @energy_tariff.flat_rate?
        redirect_to edit_school_energy_tariff_energy_tariff_flat_prices_path(@school, @energy_tariff)
      else
        redirect_to edit_school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
      end
    end
  end
end
