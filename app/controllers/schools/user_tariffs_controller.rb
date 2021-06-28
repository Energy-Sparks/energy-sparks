module Schools
  class UserTariffsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
      @user_tariffs = @school.user_tariffs.by_name
    end

    def new
      @user_tariff = @school.user_tariffs.build(user_tariff_params.merge(start_date: Date.parse('2021-04-01'), end_date: Date.parse('2022-03-31')))
    end

    def create
      @user_tariff = @school.user_tariffs.build(user_tariff_params)
      if @user_tariff.save
        redirect_to choose_type_school_user_tariff_path(@school, @user_tariff)
      else
        render :new
      end
    end

    def choose_meters
    end

    def choose_type
    end

    def update
      if @user_tariff.update(user_tariff_params)
        redirect_to school_user_tariff_user_tariff_prices_path(@school, @user_tariff)
      else
        render :edit
      end
    end

    def show
    end

    def destroy
      @user_tariff.destroy
      redirect_to school_user_tariffs_path(@school)
    end

    private

    def user_tariff_params
      params.require(:user_tariff).permit(:fuel_type, :name, :start_date, :end_date, :flat_rate, :vat_rate, meter_ids: [])
    end
  end
end
