module Onboarding
  class MetersController < ApplicationController
    def new
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
      @meter = @school_onboarding.school.meters.new
    end

    def create
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
      @meter = @school_onboarding.school.meters.new(meter_params)
      if @meter.save
        MeterManagement.new(@meter).process_creation!
        redirect_to new_onboarding_completion_path(@school_onboarding.uuid)
      else
        render :new
      end
    end

  private

    def meter_params
      params.require(:meter).permit(:mpan_mprn, :meter_type, :name, :meter_serial_number)
    end
  end
end
