module Schools
  class MetersController < ApplicationController
    before_action :set_school

    def index
      load_meters
      @new_meter = @school.meters.new
    end

    def create
      @new_meter = @school.meters.new(meter_params)
      authorize! :create, @new_meter
      if @new_meter.save
        MeterManagement.new(@new_meter).process_creation!
        redirect_to school_meters_path(@school)
      else
        load_meters
        render :index
      end
    end

    def edit
      @meter = @school.meters.find(params[:id])
      authorize! :update, @meter
    end

    def update
      @meter = @school.meters.find(params[:id])
      authorize! :update, @meter
      if @meter.update(meter_params)
        if @meter.mpan_mprn_previously_changed?
          MeterManagement.new(@meter).process_mpan_mpnr_change!
        end
        redirect_to school_meters_path(@school), notice: 'Meter updated'
      else
        render :edit
      end
    end

    def deactivate
      meter = @school.meters.active.find(params[:id])
      authorize! :update, meter
      meter.update!(active: false)
      redirect_to school_meters_path(@school), notice: 'Meter deactivated'
    end

    def activate
      meter = @school.meters.inactive.find(params[:id])
      authorize! :update, meter
      meter.update!(active: true)
      redirect_to school_meters_path(@school), notice: 'Meter deactivated'
    end

    def destroy
      meter = @school.meters.inactive.find(params[:id])
      authorize! :destroy, meter
      meter.safe_destroy
      redirect_to school_meters_path(@school)
    rescue EnergySparks::SafeDestroyError => e
      redirect_to school_meters_path(@school), alert: "Delete failed: #{e.message}"
    end

  private

    def load_meters
      @active_meters = @school.meters.active.order(:mpan_mprn)
      @inactive_meters = @school.meters.inactive.order(:mpan_mprn)
      @invalid_mpan = @active_meters.select(&:electricity?).reject(&:correct_mpan_check_digit?)
    end

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :manage, Meter
    end

    def meter_params
      params.require(:meter).permit(:mpan_mprn, :meter_type, :name, :meter_serial_number)
    end
  end
end
