module EnergyTariffs
  class EnergyTariffPricesController < ApplicationController
    include Adminable
    include EnergyTariffable
    include EnergyTariffsHelper

    load_and_authorize_resource :school, instance_name: 'tariff_holder'
    load_and_authorize_resource :school_group, instance_name: 'tariff_holder'
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: :site_settings_resource?
    before_action :load_site_setting, if: :site_settings_resource?

    def index
      if @energy_tariff.tariff_type == 'flat_rate'
        redirect_energy_tariff_flat_prices_path
      else
        redirect_energy_tariff_differential_prices_path
      end
    end

    def new
      if @energy_tariff.tariff_type == 'flat_rate'
        redirect_to_new_energy_tariff_differential_prices_path
      else
        redirect_to_new_energy_tariff_differential_prices_path
      end
    end

    def edit
      if @energy_tariff.tariff_type == 'flat_rate'
        redirect_to_edit_energy_tariff_flat_prices_path
      else
        redirect_to_edit_energy_tariff_differential_prices_path
      end
    end

    private

    def redirect_to_new_energy_tariff_differential_prices_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_differential_prices], { action: :new })
    end

    def redirect_to_new_energy_tariff_flat_prices_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_flat_prices], { action: :new })
    end

    def redirect_to_edit_energy_tariff_differential_prices_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_differential_prices], { action: :edit })
    end

    def redirect_to_edit_energy_tariff_flat_prices_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_flat_prices], { action: :edit })
    end

    def redirect_energy_tariff_flat_prices_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_flat_prices])
    end

    def redirect_energy_tariff_differential_prices_path
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_differential_prices])
    end
  end
end
