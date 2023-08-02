module EnergyTariffs
  class EnergyTariffFlatPricesController < ApplicationController
    include EnergyTariffable

    load_and_authorize_resource :school
    load_and_authorize_resource :energy_tariff
    before_action :load_and_authorize_if_site_setting

    def index
      if @energy_tariff.energy_tariff_prices.any?
        redirect_to_edit_energy_tariff_flat_price_path
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

    def redirect_to_edit_energy_tariff_flat_price_path
      if @school
        redirect_to edit_school_energy_tariff_energy_tariff_flat_price_path(@school, @energy_tariff, @energy_tariff.energy_tariff_prices.first)
      elsif @site_setting
        redirect_to edit_admin_settings_energy_tariff_energy_tariff_flat_price_path(@energy_tariff, @energy_tariff.energy_tariff_prices.first)
      end
    end

    def redirect_to_new_energy_tariff_flat_price_path
      if @school
        redirect_to new_school_energy_tariff_energy_tariff_flat_price_path(@school, @energy_tariff)
      elsif @site_setting
        redirect_to new_admin_setting_energy_tariff_energy_tariff_flat_price_path(@school, @energy_tariff)
      end
    end

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
