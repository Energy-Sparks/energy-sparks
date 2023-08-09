module EnergyTariffs
  class EnergyTariffChargesController < ApplicationController
    include Adminable
    include EnergyTariffable

    load_and_authorize_resource :school
    load_and_authorize_resource :school_group
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: :site_settings_resource?
    before_action :load_site_setting, if: :site_settings_resource?

    def index
      @energy_tariff_charges = @energy_tariff.energy_tariff_charges
    end

    def create
      @energy_tariff_charges = make_charges(params[:energy_tariff_charges], @energy_tariff)
      @energy_tariff_charges.map(&:valid?)
      if @energy_tariff_charges.all?(&:valid?)
        EnergyTariff.transaction do
          @energy_tariff.update(energy_tariff_params)
          @energy_tariff.energy_tariff_charges.destroy_all
          @energy_tariff_charges.each(&:save!)
        end
        case @energy_tariff.tariff_holder_type
        when 'School' then redirect_to school_energy_tariff_path(@school, @energy_tariff)
        when 'SchoolGroup' then redirect_to school_group_energy_tariff_path(@school_group, @energy_tariff)
        when 'SiteSettings' then redirect_to admin_settings_energy_tariff_path(@energy_tariff)
        end
      else
        render :index
      end
    end

    private

    def make_charges(defs, energy_tariff)
      defs.keys.map do |type|
        if EnergyTariffCharge.charge_types.key?(type.to_sym)
          value = defs[type][:value]
          units = defs[type][:units]
          if value.present?
            EnergyTariffCharge.new(charge_type: type, value: value, units: units, energy_tariff: energy_tariff)
          end
        end
      end.compact
    end

    def energy_tariff_params
      params.require(:energy_tariff_charges).permit(energy_tariff: [:vat_rate, :ccl, :tnuos])[:energy_tariff]
    end
  end
end
