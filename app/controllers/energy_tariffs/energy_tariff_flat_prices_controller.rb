module EnergyTariffs
  class EnergyTariffFlatPricesController < ApplicationController
    include Adminable
    include EnergyTariffable
    include EnergyTariffsHelper

    load_and_authorize_resource :school, instance_name: 'tariff_holder'
    load_and_authorize_resource :school_group, instance_name: 'tariff_holder'
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: :site_settings_resource?
    before_action :load_site_setting, if: :site_settings_resource?
    before_action :build_breadcrumbs, unless: -> { @tariff_holder.site_settings? }

    def index
      if @energy_tariff.energy_tariff_prices.any?
        redirect_to_edit_energy_tariff_flat_price_path
      else
        redirect_to_new_energy_tariff_flat_price_path
      end
    end

    def new
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.build
    end

    def create
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.build(energy_tariff_price_params.merge(default_attributes))
      if @energy_tariff_price.save
        redirect_to_energy_tariff_charges_path
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
        redirect_to_energy_tariff_charges_path
      else
        render :edit
      end
    end

    private

    def redirect_to_energy_tariff_charges_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_charges])
    end

    def redirect_to_edit_energy_tariff_flat_price_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_flat_price], { id: @energy_tariff.energy_tariff_prices.first, action: :edit })
    end

    def redirect_to_new_energy_tariff_flat_price_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_flat_price], { action: :new })
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
