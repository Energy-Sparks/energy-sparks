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

  private

    def load_meters
      @active_meters = @school.meters.active
      @inactive_meters = @school.meters.inactive
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
