module Onboarding
  class MetersController < BaseController
    def new
      @meter = @school_onboarding.school.meters.new
    end

    def create
      @meter = @school_onboarding.school.meters.new(meter_params)
      if @meter.save
        MeterManagement.new(@meter).process_creation!
        redirect_to new_onboarding_completion_path(@school_onboarding)
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
