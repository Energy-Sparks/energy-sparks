module Schools
  class UserTariffsController < ApplicationController
    load_resource :school
    load_resource :user_tariff

    def index
    end

    def new
      @user_tariff = UserTariff.new(fuel_type: params[:fuel_type], start_date: Date.parse('2021-04-01'), end_date: Date.parse('2022-03-31'))
    end

    def create
      @user_tariff = UserTariff.new(user_tariff_params)
      if @user_tariff.save
        redirect_to school_user_tariff_user_tariff_prices_path(@school, @user_tariff)
      else
        render :new
      end
    end

    def show
    end

    private

    def user_tariff_params
      params.require(:user_tariff).permit(:fuel_type, :name, :start_date, :end_date)
    end
  end
end
