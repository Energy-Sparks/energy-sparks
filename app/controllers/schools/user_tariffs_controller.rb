module Schools
  class UserTariffsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user_tariff

    def index
      @electricity_meters = @school.meters.electricity
      @electricity_tariffs = @school.user_tariffs.electricity.by_name
      @gas_meters = @school.meters.gas
      @gas_tariffs = @school.user_tariffs.gas.by_name
    end

    def new
      @user_tariff = @school.user_tariffs.build(user_tariff_params.merge(default_params))
      if @user_tariff.meter_ids.empty?
        redirect_back fallback_location: school_user_tariffs_path(@school), notice: "Please select at least one meter for this tariff"
      end
    end

    def create
      @user_tariff = @school.user_tariffs.build(user_tariff_params)
      if @user_tariff.save
        if @user_tariff.gas?
          redirect_to school_user_tariff_user_tariff_prices_path(@school, @user_tariff)
        else
          redirect_to choose_type_school_user_tariff_path(@school, @user_tariff)
        end
      else
        render :new
      end
    end

    def choose_meters
      if params[:fuel_type] == 'electricity'
        @meters = @school.meters.electricity
      elsif params[:fuel_type] == 'gas'
        @meters = @school.meters.gas
      else
        @meters = []
      end
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

    def default_params
      { start_date: Date.parse('2021-04-01'), end_date: Date.parse('2022-03-31'), flat_rate: true }
    end

    def user_tariff_params
      params.require(:user_tariff).permit(:fuel_type, :name, :start_date, :end_date, :flat_rate, :vat_rate, meter_ids: [])
    end
  end
end
