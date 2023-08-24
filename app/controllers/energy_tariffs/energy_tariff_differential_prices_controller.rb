module EnergyTariffs
  class EnergyTariffDifferentialPricesController < EnergyTariffsBaseController
    before_action :redirect_if_dcc

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
          @energy_tariff.update!(updated_by: current_user)
          format.html { redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_differential_prices]) }
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
            redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_differential_prices])
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
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_differential_prices])
    end

    def reset
      @energy_tariff.energy_tariff_prices.delete_all
      EnergyTariffDefaultPricesCreator.new(@energy_tariff).process
      redirect_to energy_tariffs_path(@energy_tariff, [:energy_tariff_differential_prices])
    end

    private

    def energy_tariff_price_params
      params.require(:energy_tariff_price).permit(:start_time, :end_time, :value, :description)
    end
  end
end
