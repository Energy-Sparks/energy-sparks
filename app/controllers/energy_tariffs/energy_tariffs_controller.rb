module EnergyTariffs
  class EnergyTariffsController < EnergyTariffsBaseController
    before_action :redirect_if_dcc, only: [:edit_meters, :update_meters, :choose_type, :destroy, :edit]

    def index
      authorize! :manage, @tariff_holder.energy_tariffs.build

      if @tariff_holder.school?
        @electricity_meters = @tariff_holder.meters.electricity
        @gas_meters = @tariff_holder.meters.gas
      end
    end

    def default_tariffs
    end

    def smart_meter_tariffs
    end

    def group_school_tariffs
      redirect_to polymorphic_path(tariff_holder_route(@tariff_holder) + [:energy_tariffs]) and return unless @tariff_holder.school_group?
    end

    def show
    end

    def new
      @energy_tariff = @tariff_holder.energy_tariffs.build(default_params.merge({ meter_type: params[:meter_type] }))
    end

    def create
      @energy_tariff = @tariff_holder.energy_tariffs.build(energy_tariff_params.merge(created_by: current_user))
      if @energy_tariff.save
        redirect_to energy_tariffs_path(@energy_tariff)
      else
        render :new
      end
    end

    def update
      if @energy_tariff.update(energy_tariff_params.merge(updated_by: current_user))
        redirect_to energy_tariffs_path(@energy_tariff)
      else
        render :edit
      end
    end

    def edit_meters
      if @energy_tariff.electricity?
        @meters = @tariff_holder.meters.electricity
      elsif @energy_tariff.gas?
        @meters = @tariff_holder.meters.gas
      else
        @meters = []
      end
    end

    def update_meters
      redirect_back fallback_location: school_energy_tariffs_path(@tariff_holder), notice: I18n.t('schools.user_tariffs.choose_meters.missing_meters') and return if require_meters?

      @energy_tariff.meter_ids = energy_tariff_params[:meter_ids]
      @energy_tariff.applies_to = energy_tariff_params[:applies_to].present? ? energy_tariff_params[:applies_to] : :both
      @energy_tariff.updated_by = current_user

      if @energy_tariff.save!
        redirect_to energy_tariffs_path(@energy_tariff)
      else
        render :edit_meters
      end
    end

    def applies_to
    end

    def update_applies_to
      if @energy_tariff.update!(applies_to: energy_tariff_params['applies_to'])
        redirect_to energy_tariffs_path(@energy_tariff)
      else
        render :applies_to
      end
    end

    def choose_type
    end

    def update_type
      @energy_tariff.tariff_type = energy_tariff_params['tariff_type']
      redirect_to energy_tariffs_path(@energy_tariff) and return unless @energy_tariff.tariff_type_changed?

      @energy_tariff.updated_by = current_user

      if @energy_tariff.save!
        @energy_tariff.energy_tariff_prices.destroy_all
        redirect_to energy_tariffs_path(@energy_tariff)
      else
        render :choose_type
      end
    end

    def toggle_enabled
      @energy_tariff.toggle!(:enabled)
    end

    def destroy
      redirect_path = energy_tariffs_path(@energy_tariff, [], { energy_tariff_index: true })
      @energy_tariff.destroy
      redirect_to redirect_path
    end

    private

    def require_meters?
      !params[:all_meters] && params[:energy_tariff][:meter_ids].reject(&:empty?).empty?
    end

    def default_params
      default_start_date = @tariff_holder.default_tariff_start_date(@energy_tariff.meter_type)
      default_end_date = default_start_date + 1.year
      {
        start_date: default_start_date,
        end_date: default_end_date
      }
    end

    def energy_tariff_params
      params.require(:energy_tariff).permit(:meter_type, :name, :start_date, :end_date, :tariff_type, :vat_rate, :applies_to, meter_ids: [])
    end
  end
end
