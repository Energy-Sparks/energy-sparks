module Schools
  class UserTariffPricesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
    end

    def new
      @user_tariff_price = @user_tariff.user_tariff_prices.build
      respond_to do |format|
        format.html
        format.js
      end
    end

    def create
      @user_tariff_price = @user_tariff.user_tariff_prices.build(user_tariff_price_params.merge(units: 'kwh'))
      respond_to do |format|
        if @user_tariff_price.save
          format.html { redirect_to school_user_tariff_user_tariff_prices_path(@school, @user_tariff) }
          format.js
        else
          format.html { render :new }
          format.js { render :new }
        end
      end
    end

    def edit
      @user_tariff_price = @user_tariff.user_tariff_prices.find(params[:id])
      respond_to do |format|
        format.html
        format.js
      end
    end

    def update
      @user_tariff_price = @user_tariff.user_tariff_prices.find(params[:id])
      respond_to do |format|
        if @user_tariff_price.update(user_tariff_price_params)
          format.html { redirect_to school_user_tariff_user_tariff_prices_path(@school, @user_tariff) }
          format.js
        else
          format.html { render :edit }
          format.js { render :edit }
        end
      end
    end

    def destroy
      @user_tariff.user_tariff_prices.find(params[:id]).destroy
      redirect_to school_user_tariff_user_tariff_prices_path(@school, @user_tariff)
    end

    private

    def user_tariff_price_params
      params.require(:user_tariff_price).permit(:start_time, :end_time, :value)
    end
  end
end
