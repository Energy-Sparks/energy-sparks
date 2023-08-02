module EnergyTariffs
  class EnergyTariffPricesController < ApplicationController
    include EnergyTariffable

    load_and_authorize_resource :school
    load_and_authorize_resource :energy_tariff
    before_action :load_and_authorize_if_site_setting

    def index
      if @energy_tariff.tariff_type == 'flat_rate'
        redirect_energy_tariff_flat_prices_path
      else
        redirect_energy_tariff_differential_prices_path
      end
    end

    def new
      if @energy_tariff.tariff_type == 'flat_rate'
        redirect_to new_school_energy_tariff_energy_tariff_flat_prices_path(@school, @energy_tariff)
      else
        redirect_to new_school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
      end
    end

    def edit
      if @energy_tariff.tariff_type == 'flat_rate'
        redirect_to edit_school_energy_tariff_energy_tariff_flat_prices_path(@school, @energy_tariff)
      else
        redirect_to edit_school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
      end
    end

    private

    def redirect_energy_tariff_flat_prices_path
      if @school
        redirect_to school_energy_tariff_energy_tariff_flat_prices_path(@school, @energy_tariff)
      elsif @site_setting
        redirect_to admin_settings_energy_tariff_energy_tariff_flat_prices_path(@energy_tariff)
      end
    end

    def redirect_energy_tariff_differential_prices_path
      if @school
        redirect_to school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
      elsif @site_setting
        redirect_to admin_settings_energy_tariff_energy_tariff_differential_prices_path(@energy_tariff)
      end
    end
  end
end
