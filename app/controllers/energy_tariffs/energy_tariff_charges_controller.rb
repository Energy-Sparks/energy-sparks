module EnergyTariffs
  class EnergyTariffChargesController < EnergyTariffsBaseController
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
        @energy_tariff.update!(updated_by: current_user)
        redirect_to energy_tariffs_path(@energy_tariff)
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
