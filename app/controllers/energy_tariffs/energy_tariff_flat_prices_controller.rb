module EnergyTariffs
  class EnergyTariffFlatPricesController < ApplicationController
    include Adminable
    include EnergyTariffable

    load_and_authorize_resource :school
    load_and_authorize_resource :school_group
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: :site_settings_resource?
    before_action :load_site_setting, if: :site_settings_resource?

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

    def redirect_to_energy_tariff_charges_path
      case @energy_tariff.tariff_holder_type
      when 'School' then redirect_to school_energy_tariff_energy_tariff_charges_path(@school, @energy_tariff)
      when 'SchoolGroup' then redirect_to school_group_energy_tariff_energy_tariff_charges_path(@school_group, @energy_tariff)
      when 'SiteSettings' then redirect_to admin_settings_energy_tariff_energy_tariff_charges_path(@energy_tariff)
      end
    end

    def edit
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.find(params[:id])
    end

    def update
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.find(params[:id])
      if @energy_tariff_price.update(energy_tariff_price_params)
        case @energy_tariff.tariff_holder_type
        when 'School' then redirect_to school_energy_tariff_energy_tariff_charges_path(@school, @energy_tariff)
        when 'SchoolGroup' then redirect_to school_group_energy_tariff_energy_tariff_charges_path(@school_group, @energy_tariff)
        when 'SiteSettings' then redirect_to admin_settings_energy_tariff_energy_tariff_charges_path(@energy_tariff)
        end
      else
        render :edit
      end
    end

    private

    def redirect_to_edit_energy_tariff_flat_price_path
      case @energy_tariff.tariff_holder_type
      when 'School' then redirect_to edit_school_energy_tariff_energy_tariff_flat_price_path(@school, @energy_tariff, @energy_tariff.energy_tariff_prices.first)
      when 'SchoolGroup' then redirect_to edit_school_group_energy_tariff_energy_tariff_flat_price_path(@school_group, @energy_tariff, @energy_tariff.energy_tariff_prices.first)
      when 'SiteSettings' then redirect_to edit_admin_settings_energy_tariff_energy_tariff_flat_price_path(@energy_tariff, @energy_tariff.energy_tariff_prices.first)
      end
    end

    def redirect_to_new_energy_tariff_flat_price_path
      case @energy_tariff.tariff_holder_type
      when 'School' then redirect_to new_school_energy_tariff_energy_tariff_flat_price_path(@school, @energy_tariff)
      when 'SchoolGroup' then redirect_to new_school_group_energy_tariff_energy_tariff_flat_price_path(@school_group, @energy_tariff)
      when 'SiteSettings' then redirect_to new_admin_settings_energy_tariff_energy_tariff_flat_price_path(@energy_tariff)
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
