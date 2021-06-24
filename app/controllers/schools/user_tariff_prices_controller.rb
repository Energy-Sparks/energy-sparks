module Schools
  class UserTariffPricesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
      if @user_tariff.flat_rate?
        redirect_to school_user_tariff_user_tariff_flat_prices_path(@school, @user_tariff)
      else
        redirect_to school_user_tariff_user_tariff_differential_prices_path(@school, @user_tariff)
      end
    end

    def new
      if @user_tariff.flat_rate?
        redirect_to new_school_user_tariff_user_tariff_flat_prices_path(@school, @user_tariff)
      else
        redirect_to new_school_user_tariff_user_tariff_differential_prices_path(@school, @user_tariff)
      end
    end

    def edit
      if @user_tariff.flat_rate?
        redirect_to edit_school_user_tariff_user_tariff_flat_prices_path(@school, @user_tariff)
      else
        redirect_to edit_school_user_tariff_user_tariff_differential_prices_path(@school, @user_tariff)
      end
    end
  end
end
