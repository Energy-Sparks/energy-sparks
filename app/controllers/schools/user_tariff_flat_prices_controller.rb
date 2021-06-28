module Schools
  class UserTariffFlatPricesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
      if @user_tariff.user_tariff_prices.any?
        redirect_to edit_school_user_tariff_user_tariff_flat_price_path(@school, @user_tariff, @user_tariff.user_tariff_prices.first)
      else
        redirect_to new_school_user_tariff_user_tariff_flat_price_path(@school, @user_tariff)
      end
    end

    def new
      @user_tariff_price = @user_tariff.user_tariff_prices.build
    end

    def create
      @user_tariff_price = @user_tariff.user_tariff_prices.build(user_tariff_price_params.merge(default_attributes))
      if @user_tariff_price.save
        redirect_to school_user_tariff_user_tariff_charges_path(@school, @user_tariff)
      else
        render :new
      end
    end

    def edit
      @user_tariff_price = @user_tariff.user_tariff_prices.find(params[:id])
    end

    def update
      @user_tariff_price = @user_tariff.user_tariff_prices.find(params[:id])
      if @user_tariff_price.update(user_tariff_price_params)
         redirect_to school_user_tariff_user_tariff_charges_path(@school, @user_tariff)
      else
        render :edit
      end
    end

    private

    def default_attributes
      {
        units: 'kwh',
        start_time: Time.zone.parse('00:00'),
        end_time: Time.zone.parse('23:30')
      }
    end

    def user_tariff_price_params
      params.require(:user_tariff_price).permit(:value)
    end
  end
end
