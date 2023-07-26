module Schools
  class EnergyTariffsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :energy_tariff
    before_action :set_breadcrumbs

    def index
      @electricity_meters = @school.meters.electricity
      @electricity_tariffs = @school.energy_tariffs.electricity.by_start_date.by_name
      @gas_meters = @school.meters.gas
      @gas_tariffs = @school.energy_tariffs.gas.by_start_date.by_name
    end

    def new
      @energy_tariff = @school.energy_tariffs.build(energy_tariff_params.merge(default_params))
      if @energy_tariff.meter_ids.empty?
        redirect_back fallback_location: school_energy_tariffs_path(@school), notice: "Please select at least one meter for this tariff"
      end
    end

    def create
      @energy_tariff = @school.energy_tariffs.build(energy_tariff_params)
      if @energy_tariff.save
        if @energy_tariff.gas?
          redirect_to school_energy_tariff_energy_tariff_prices_path(@school, @energy_tariff)
        else
          redirect_to choose_type_school_energy_tariff_path(@school, @energy_tariff)
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
      if @energy_tariff.update(energy_tariff_params)
        EnergyTariffDefaultPricesCreator.new(@energy_tariff).process
        redirect_to school_energy_tariff_energy_tariff_prices_path(@school, @energy_tariff)
      else
        render :edit
      end
    end

    def show
    end

    def destroy
      @energy_tariff.destroy
      redirect_to school_energy_tariffs_path(@school)
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_tariffs') }]
    end

    def default_params
      { start_date: Date.parse('2021-04-01'), end_date: Date.parse('2022-03-31'), tariff_type: :flat_rate }
    end

    def energy_tariff_params
      # params.require(:energy_tariff).permit(:meter_type, :name, :start_date, :end_date, :flat_rate, :vat_rate, meter_ids: [])
      params.require(:energy_tariff).permit(:meter_type, :name, :start_date, :end_date, :tariff_type, :vat_rate, meter_ids: [])
    end
  end
end
