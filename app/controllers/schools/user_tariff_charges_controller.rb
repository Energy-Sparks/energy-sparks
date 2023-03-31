module Schools
  class UserTariffChargesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
      @user_tariff_charges = @user_tariff.user_tariff_charges
    end

    def create
      user_tariff_charges = make_charges(params[:user_tariff_charges], @user_tariff)
      validator = UserTariffChargeValidator.new(user_tariff_charges)
      if validator.valid?
        UserTariff.transaction do
          @user_tariff.update(user_tariff_params)
          @user_tariff.user_tariff_charges.destroy_all
          validator.user_tariff_charges.each(&:save!)
        end
        redirect_to school_user_tariff_path(@school, @user_tariff)
      else
        @user_tariff_charges = validator.user_tariff_charges
        flash[:error] = validator.message
        render :index
      end
    end

    private

    def make_charges(defs, user_tariff)
      defs.keys.map do |type|
        if UserTariffCharge.charge_types.key?(type.to_sym)
          value = defs[type][:value]
          units = defs[type][:units]
          if value.present?
            UserTariffCharge.new(charge_type: type, value: value, units: units, user_tariff: user_tariff)
          end
        end
      end.compact
    end

    def user_tariff_params
      params.require(:user_tariff_charges).permit(user_tariff: [:vat_rate, :ccl, :tnuos])[:user_tariff]
    end
  end
end
