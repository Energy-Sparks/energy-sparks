module Schools
  class UserTariffChargesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
    end

    def new
      @user_tariff_charge = @user_tariff.user_tariff_charges.build
    end

    def create
      @user_tariff_charge = @user_tariff.user_tariff_charges.build(user_tariff_charge_params)
      if @user_tariff_charge.save
        redirect_to school_user_tariff_user_tariff_charges_path(@school, @user_tariff)
      else
        render :new
      end
    end

    def edit
      @user_tariff_charge = @user_tariff.user_tariff_charges.find(params[:id])
    end

    def update
      @user_tariff_charge = @user_tariff.user_tariff_charges.find(params[:id])
      if @user_tariff_charge.update(user_tariff_charge_params)
        redirect_to school_user_tariff_user_tariff_charges_path(@school, @user_tariff)
      else
        render :edit
      end
    end

    def destroy
      @user_tariff.user_tariff_charges.find(params[:id]).destroy
      redirect_to school_user_tariff_user_tariff_charges_path(@school, @user_tariff)
    end

    private

    def user_tariff_charge_params
      params.require(:user_tariff_charge).permit(:charge_type, :value, :units)
    end
  end
end
