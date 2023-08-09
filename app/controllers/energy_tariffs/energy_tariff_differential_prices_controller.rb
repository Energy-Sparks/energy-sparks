module EnergyTariffs
  class EnergyTariffDifferentialPricesController < ApplicationController
    include Adminable
    include EnergyTariffable

    load_and_authorize_resource :school
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: -> { request.path.start_with?('/admin/settings') || @energy_tariff&.tariff_holder_type == 'SiteSettings' }
    before_action :load_site_setting

    def index
    end

    def new
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.build
      respond_to do |format|
        format.html
        format.js
      end
    end

    def create
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.build(energy_tariff_price_params.merge(units: 'kwh'))
      respond_to do |format|
        if @energy_tariff_price.save
          format.html { redirect_to school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff) }
          format.js
        else
          format.html { render :new }
          format.js { render :new }
        end
      end
    end

    def edit
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.find(params[:id])
      respond_to do |format|
        format.html
        format.js
      end
    end

    def update
      @energy_tariff_price = @energy_tariff.energy_tariff_prices.find(params[:id])
      respond_to do |format|
        if @energy_tariff_price.update(energy_tariff_price_params)
          format.html do
            case @energy_tariff.tariff_holder_type
            when 'School' then redirect_to school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
            when 'SiteSettings' then redirect_to admin_settings_energy_tariff_energy_tariff_differential_prices_path(@energy_tariff)
            end
          end
          format.js
        else
          format.html { render :edit }
          format.js { render :edit }
        end
      end
    end

    def destroy
      @energy_tariff.energy_tariff_prices.find(params[:id]).destroy
      case @energy_tariff.tariff_holder_type
      when 'School' then redirect_to school_energy_tariff_energy_tariff_differential_prices_path(@school, @energy_tariff)
      when 'SiteSettings' then redirect_to admin_settings_energy_tariff_energy_tariff_differential_prices_path(@energy_tariff)
      end
    end

    private

    def energy_tariff_price_params
      params.require(:energy_tariff_price).permit(:start_time, :end_time, :value)
    end
  end
end
