module EnergyTariffs
  class EnergyTariffsController < ApplicationController
    include Adminable
    include EnergyTariffable

    load_and_authorize_resource :school
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: :site_settings_resource?
    before_action :load_site_setting, if: :site_settings_resource?
    before_action :set_breadcrumbs

    def index
      if @school
        @electricity_meters = @school.meters.electricity
        @electricity_tariffs = @school.energy_tariffs.electricity.by_start_date.by_name
        @gas_meters = @school.meters.gas
        @gas_tariffs = @school.energy_tariffs.gas.by_start_date.by_name
      end
    end

    def new
      @energy_tariff = if @school
                         @school.energy_tariffs.build(energy_tariff_params.merge(default_params))
                       elsif @site_setting
                         @site_setting.energy_tariffs.build(meter_type: params[:meter_type])
                       end
      if @energy_tariff.meter_ids.empty? && @school
        redirect_back fallback_location: school_energy_tariffs_path(@school), notice: "Please select at least one meter for this tariff"
      end
    end

    def create
      @energy_tariff = if @school
                         @school.energy_tariffs.build(energy_tariff_params.merge(created_by: current_user))
                       elsif @site_setting
                         @site_setting.energy_tariffs.build(energy_tariff_params.merge(created_by: current_user))
                       end

      if @energy_tariff.save
        if @energy_tariff.gas?
          redirect_to_energy_tariff_prices_path
        else
          redirect_to_choose_type_energy_tariff_path
        end
      else
        render :new
      end
    end

    def choose_meters
      if params[:meter_type] == 'electricity'
        @meters = @school.meters.electricity
      elsif params[:meter_type] == 'gas'
        @meters = @school.meters.gas
      else
        @meters = []
      end
    end

    def choose_type
    end

    def update
      if @energy_tariff.update(energy_tariff_params.merge(updated_by: current_user))
        EnergyTariffDefaultPricesCreator.new(@energy_tariff).process
        case @energy_tariff.tariff_holder_type
        when 'School' then redirect_to school_energy_tariff_energy_tariff_prices_path(@school, @energy_tariff)
        when 'SiteSettings' then redirect_to admin_settings_energy_tariff_energy_tariff_prices_path(@energy_tariff)
        end
      else
        render :edit
      end
    end

    def show
    end

    def destroy
      redirect_path = case @energy_tariff.tariff_holder_type
                      when 'School' then school_energy_tariffs_path(@school)
                      when 'SiteSettings' then admin_settings_energy_tariffs_path
                      end

      @energy_tariff.destroy
      redirect_to redirect_path
    end

    private

    def redirect_to_choose_type_energy_tariff_path
      case @energy_tariff.tariff_holder_type
      when 'School' then redirect_to choose_type_school_energy_tariff_path(@school, @energy_tariff)
      when 'SiteSettings' then redirect_to choose_type_admin_settings_energy_tariff_path(@energy_tariff)
      end
    end

    def redirect_to_energy_tariff_prices_path
      case @energy_tariff.tariff_holder_type
      when 'School' then redirect_to school_energy_tariff_energy_tariff_prices_path(@school, @energy_tariff)
      when 'SiteSettings' then redirect_to admin_settings_energy_tariff_energy_tariff_prices_path(@energy_tariff)
      end
    end

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_tariffs') }]
    end

    def default_params
      { start_date: Date.parse('2021-04-01'), end_date: Date.parse('2022-03-31'), tariff_type: :flat_rate }
    end

    def energy_tariff_params
      params.require(:energy_tariff).permit(:meter_type, :name, :start_date, :end_date, :tariff_type, :vat_rate, meter_ids: [])
    end
  end
end
