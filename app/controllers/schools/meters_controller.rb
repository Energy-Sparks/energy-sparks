module Schools
  class MetersController < ApplicationController
    before_action :set_school

    def index
      load_meters
      @new_meter = @school.meters.new
    end

    def create
      @new_meter = @school.meters.new(meter_params)
      if @new_meter.save
        redirect_to school_meters_path(@school)
      else
        load_meters
        render :index
      end
    end

    def edit
      @meter = @school.meters.find(params[:id])
    end

    def update
      @meter = @school.meters.find(params[:id])
      if @meter.update(meter_params)
        redirect_to school_meters_path(@school), notice: 'Meter updated'
      else
        render :edit
      end
    end

    def deactivate
      meter = @school.meters.active.find(params[:id])
      meter.update!(active: false)
      redirect_to school_meters_path(@school), notice: 'Meter deactivated'
    end

    def activate
      meter = @school.meters.inactive.find(params[:id])
      meter.update!(active: true)
      redirect_to school_meters_path(@school), notice: 'Meter deactivated'
    end

    def destroy
      meter = @school.meters.inactive.find(params[:id])
      meter.safe_destroy
      redirect_to school_meters_path(@school)
    rescue EnergySparks::SafeDestroyError => e
      redirect_to school_meters_path(@school), alert: "Delete failed: #{e.message}"
    end

  private

    def load_meters
      @active_meters = @school.meters.active.order(:meter_no)
      @inactive_meters = @school.meters.inactive.order(:meter_no)
    end

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :manage, @school
    end

    def meter_params
      params.require(:meter).permit(:meter_no, :meter_type, :name)
    end
  end
end
