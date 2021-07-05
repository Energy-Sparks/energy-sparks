module Schools
  class UserTariffChargesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
      @user_tariff_charges = @user_tariff.user_tariff_charges
    end

    def new
      @user_tariff_charge = @user_tariff.user_tariff_charges.build
      respond_to do |format|
        format.html
        format.js
      end
    end

    def create
      @user_tariff_charges = make_charges(params[:user_tariff_charges], @user_tariff)
      @user_tariff_charges.map(&:valid?)
      if @user_tariff_charges.all?(&:valid?)
        UserTariff.transaction do
          @user_tariff.update(user_tariff_params)
          @user_tariff.user_tariff_charges.destroy_all
          @user_tariff_charges.each(&:save!)
        end
        redirect_to school_user_tariff_path(@school, @user_tariff)
      else
        render :index
      end
    end

    def edit
      @user_tariff_charge = @user_tariff.user_tariff_charges.find(params[:id])
      respond_to do |format|
        format.html
        format.js
      end
    end

    def update
      @user_tariff_charge = @user_tariff.user_tariff_charges.find(params[:id])
      respond_to do |format|
        if @user_tariff_charge.update(user_tariff_charge_params)
          format.html { redirect_to school_user_tariff_user_tariff_charges_path(@school, @user_tariff) }
          format.js
        else
          format.html { render :edit }
          format.js { render :edit }
        end
      end
    end

    def destroy
      @user_tariff.user_tariff_charges.find(params[:id]).destroy
      redirect_to school_user_tariff_user_tariff_charges_path(@school, @user_tariff)
    end

    private

    def make_charges(defs, user_tariff)
      defs.keys.map do |type|
        if UserTariffCharge::CHARGE_TYPES.key?(type.to_sym)
          value = defs[type][:value]
          units = defs[type][:units]
          if value.present?
            UserTariffCharge.new(charge_type: type, value: value, units: units, user_tariff: user_tariff)
          end
        end
      end.compact
    end

    def user_tariff_params
      params.require(:user_tariff_charges).permit(user_tariff: [:vat_rate, :ccl])[:user_tariff]
    end
  end
end
