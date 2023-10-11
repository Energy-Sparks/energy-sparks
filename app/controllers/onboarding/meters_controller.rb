module Onboarding
  class MetersController < BaseController
    def new
      @meter = @school_onboarding.school.meters.new
    end

    def create
      @meter = @school_onboarding.school.meters.new(meter_params)
      if @meter.save
        MeterManagement.new(@meter).process_creation!
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'meters')
      else
        render :new
      end
    end

    def edit
      @meter = @school_onboarding.school.meters.find(params[:id])
    end

    def update
      @meter = @school_onboarding.school.meters.find(params[:id])
      if @meter.update(meter_params)
        MeterManagement.new(@meter).process_mpan_mpnr_change! if @meter.mpan_mprn_previously_changed?
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'meters')
      else
        render :edit
      end
    end

    private

    def meter_params
      params.require(:meter).permit(:mpan_mprn, :meter_type, :name, :meter_serial_number)
    end
  end
end
